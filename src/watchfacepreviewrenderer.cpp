/*
 * SPDX-FileCopyrightText: 2026 Timo Könnecke <github.com/moWerk>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "watchfacepreviewrenderer.h"

#include <QQmlEngine>
#include <QQmlComponent>
#include <QQuickRenderControl>
#include <QQuickWindow>
#include <QQuickItem>
#include <QQuickRenderTarget>
#include <QGuiApplication>
#include <QScreen>
#include <QImage>
#include <QDir>
#include <QFileInfo>
#include <QLoggingCategory>
#include <QSaveFile>
#include <QStandardPaths>
#include <QTimer>
#include <rhi/qrhi.h>

Q_LOGGING_CATEGORY(lcWfPreview, "asteroid.launcher.wfpreview")

namespace {
// The GPU readback is a synchronous stall on the compositor's GUI thread, so we
// do exactly ONE per attempt: render blindly for a short warm-up (pumping frames
// so Canvas workers and async Image/font loads complete), then read back once and
// gate on content. A face that needs longer than the warm-up reads back blank and
// is requeued with a longer warm-up (kRetryExtraTicks) rather than hammering
// readbacks.
constexpr int    kSettleInterval    = 100;   // ms between render ticks
constexpr int    kSettleTicks       = 5;     // ~500 ms warm-up before the readback
constexpr int    kRetryExtraTicks   = 6;     // each retry renders this many ticks longer
constexpr int    kMaxLoadWaitTicks  = 30;    // extra ticks granted while the face still loads
constexpr int    kYieldBetweenJobs  = 250;   // ms idle between faces, let the UI breathe
constexpr int    kIdleTeardownMs    = 5000;  // queue empty this long -> release the GPU stack
constexpr double kMinOpaqueFraction = 0.005; // >=0.5% opaque pixels = has content
constexpr int    kMaxRetries        = 3;     // blank grabs requeue this many times

QString faceNameFromUrl(const QUrl &url)
{
    QString n = url.fileName();          // <name>.qml
    if (n.endsWith(QStringLiteral(".qml")))
        n.chop(4);
    return n;
}

QString previewPathFor(const QString &name, int size)
{
    return QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
        + QStringLiteral("/asteroid-launcher/watchfaces-preview/")
        + QString::number(size) + QLatin1Char('/') + name + QStringLiteral(".webp");
}

// Fraction of (subsampled) pixels that are not transparent. A face that has not
// rendered yet is ~all transparent; a real preview has meaningful opaque area.
double opaqueFraction(const QImage &img)
{
    const QImage a = img.convertToFormat(QImage::Format_ARGB32);
    qint64 opaque = 0, total = 0;
    for (int y = 0; y < a.height(); y += 2) {
        const QRgb *line = reinterpret_cast<const QRgb *>(a.constScanLine(y));
        for (int x = 0; x < a.width(); x += 2) {
            ++total;
            if (qAlpha(line[x]) > 16)
                ++opaque;
        }
    }
    return total ? double(opaque) / double(total) : 0.0;
}
}

WatchfacePreviewRenderer::WatchfacePreviewRenderer(QObject *parent)
    : QObject(parent)
{
    m_settle = new QTimer(this);
    m_settle->setInterval(kSettleInterval);
    connect(m_settle, &QTimer::timeout, this, &WatchfacePreviewRenderer::renderTick);

    m_idleTeardown = new QTimer(this);
    m_idleTeardown->setSingleShot(true);
    m_idleTeardown->setInterval(kIdleTeardownMs);
    connect(m_idleTeardown, &QTimer::timeout, this, [this]() {
        if (!m_busy && m_queue.isEmpty())
            teardownGpu();
    });
}

WatchfacePreviewRenderer::~WatchfacePreviewRenderer()
{
    m_settle->stop();
    // Shutdown: the event loop will not spin again, so destroy the face item
    // directly rather than via deleteLater, before its window goes away.
    if (m_rootItem) {
        m_rootItem->setParentItem(nullptr);
        delete m_rootItem;
        m_rootItem = nullptr;
    }
    m_component.reset();
    teardownGpu();
}

void WatchfacePreviewRenderer::requestPreview(const QUrl &faceUrl, int size)
{
    if (!faceUrl.isValid() || size <= 0)
        return;

    // Skip work the disk already holds: a preview newer than the face's QML
    // cannot be stale. This is what makes the activation hook free at boot,
    // where the source binding fires for the unchanged current face.
    if (faceUrl.isLocalFile()) {
        const QFileInfo face(faceUrl.toLocalFile());
        const QFileInfo have(previewPathFor(faceNameFromUrl(faceUrl), size));
        if (face.exists() && have.exists() && have.lastModified() > face.lastModified())
            return;
    }

    if (m_busy) {
        if (m_current.url == faceUrl)
            return; // already rendering exactly this
        // A different face is wanted now; the one mid-render is stale. Abort
        // it rather than paying its warm-up and readback for a result nobody
        // asked to keep — it regenerates on its next activation.
        m_settle->stop();
        teardownFace();
        m_busy = false;
    }

    enqueue({ faceUrl, size });
    startNext();
}

void WatchfacePreviewRenderer::enqueue(const Job &job)
{
    m_idleTeardown->stop();
    // Coalesce: drop an already-queued job for the same face (keep the newest).
    for (int i = m_queue.size() - 1; i >= 0; --i)
        if (m_queue.at(i).url == job.url)
            m_queue.removeAt(i);
    m_queue.enqueue(job);
}

bool WatchfacePreviewRenderer::ensureRhi()
{
    if (m_rc)
        return true;

    m_engine = std::make_unique<QQmlEngine>();
    m_rc = std::make_unique<QQuickRenderControl>();
    m_window = std::make_unique<QQuickWindow>(m_rc.get());
    // Clear to transparent, not the default opaque white. Watchfaces carry no
    // background of their own, so an opaque clear colour bleeds straight into
    // the preview; transparent gives the square-with-alpha the round mask needs.
    m_window->setColor(Qt::transparent);
    // Offscreen: never shown. initialize() creates the QRhi.
    if (!m_rc->initialize()) {
        m_window.reset();
        m_rc.reset();
        m_engine.reset();
        return false;
    }
    return true;
}

bool WatchfacePreviewRenderer::ensureTarget(const QSize &pixelSize)
{
    if (m_rt && m_targetSize == pixelSize)
        return true;

    m_rpDesc.reset();
    m_rt.reset();
    m_ds.reset();
    m_texture.reset();

    QRhi *rhi = m_rc->rhi();
    if (!rhi)
        return false;

    m_texture.reset(rhi->newTexture(QRhiTexture::RGBA8, pixelSize, 1,
        QRhiTexture::RenderTarget | QRhiTexture::UsedAsTransferSource));
    if (!m_texture->create())
        return false;

    m_ds.reset(rhi->newRenderBuffer(QRhiRenderBuffer::DepthStencil, pixelSize, 1));
    if (!m_ds->create())
        return false;

    QRhiTextureRenderTargetDescription rtDesc(QRhiColorAttachment(m_texture.get()));
    rtDesc.setDepthStencilBuffer(m_ds.get());
    m_rt.reset(rhi->newTextureRenderTarget(rtDesc));
    m_rpDesc.reset(m_rt->newCompatibleRenderPassDescriptor());
    m_rt->setRenderPassDescriptor(m_rpDesc.get());
    if (!m_rt->create())
        return false;

    m_window->setRenderTarget(QQuickRenderTarget::fromRhiRenderTarget(m_rt.get()));
    m_targetSize = pixelSize;
    return true;
}

void WatchfacePreviewRenderer::startNext()
{
    // A loop, not recursion: a face that fails setup drops out and the next in
    // the queue is tried immediately, so one broken face can never strand the
    // rest of the queue.
    while (!m_busy && !m_queue.isEmpty()) {
        m_current = m_queue.dequeue();

        if (!ensureRhi()) {
            qCWarning(lcWfPreview) << "offscreen init failed, dropping"
                                   << faceNameFromUrl(m_current.url);
            continue;
        }

        // Render at the real screen size: Dims and Screen-derived layouts come
        // out right and thin strokes survive; the square crop is downscaled
        // once at save time. One size also means the render target is reused
        // across faces.
        const QSize screenPx = QGuiApplication::primaryScreen()
            ? QGuiApplication::primaryScreen()->size() : QSize(320, 320);
        if (!ensureTarget(screenPx))
            continue;

        // The offscreen engine keeps its own component cache; clear it each
        // load so a face never fails with Qt6's "File name case mismatch" (the
        // launcher's main engine clears its cache for the same reason).
        m_engine->clearComponentCache();

        // Mirror the context MainScreen gives a real watchface so faces render
        // the same offscreen: live wallClock, plus stubs shaped like the real
        // objects a face may dereference. A face reached through the Loader
        // resolves these up the enclosing scope. The Loader is asynchronous so
        // instantiating a heavy face does not block the compositor thread;
        // renderTick waits for it before grabbing.
        const QString wrapper = QStringLiteral(
            "import QtQuick\n"
            "import org.asteroid.utils\n"
            "Item {\n"
            "  property bool nightstand: false\n"
            "  property bool displayAmbient: false\n"
            "  property QtObject compositor: QtObject {\n"
            "    signal displayAmbientEntered()\n"
            "    signal displayAmbientLeft()\n"
            "  }\n"
            "  property QtObject use12H: QtObject { property bool value: false }\n"
            "  property QtObject batteryChargePercentage: QtObject { property int percent: 100 }\n"
            "  property QtObject localeManager: QtObject { property string changesObserver: \"\" }\n"
            "  WallClock { id: _wc; enabled: true }\n"
            "  property var wallClock: _wc\n"
            "  property alias faceStatus: _ld.status\n"
            "  Loader { id: _ld; anchors.fill: parent; asynchronous: true; source: \"%1\" }\n"
            "}\n").arg(m_current.url.toString());
        m_component = std::make_unique<QQmlComponent>(m_engine.get());
        m_component->setData(wrapper.toUtf8(), QUrl(QStringLiteral("qrc:/wf-preview-wrapper.qml")));
        if (m_component->isError()) {
            teardownFace();
            continue;
        }
        QObject *obj = m_component->create();
        m_rootItem = qobject_cast<QQuickItem *>(obj);
        if (!m_rootItem) {
            delete obj;
            teardownFace();
            continue;
        }
        m_rootItem->setParentItem(m_window->contentItem());
        m_rootItem->setSize(QSizeF(screenPx));
        m_window->contentItem()->setSize(QSizeF(screenPx));
        m_window->setGeometry(0, 0, screenPx.width(), screenPx.height());

        m_busy = true;
        m_frames = 0;
        m_settleTicks = kSettleTicks + m_current.attempts * kRetryExtraTicks;
        m_settle->start();
        return;
    }

    if (!m_busy && m_queue.isEmpty())
        m_idleTeardown->start();
}

void WatchfacePreviewRenderer::renderTick()
{
    QRhi *rhi = m_rc ? m_rc->rhi() : nullptr;
    if (!rhi || !m_rootItem) {
        m_settle->stop();
        finishJob(QImage(), /*rendererDied*/ true);
        return;
    }

    ++m_frames;
    // Hold the readback while the asynchronous Loader is still compiling and
    // instantiating the face, within a bound; a face that never becomes Ready
    // falls through to the blank gate and its retry budget.
    const bool faceReady = m_rootItem->property("faceStatus").toInt() == 1; // Loader.Ready
    const bool grab = m_frames >= m_settleTicks
        && (faceReady || m_frames >= m_settleTicks + kMaxLoadWaitTicks);

    // Pump a frame every tick so Canvas workers and async loads make progress,
    // but read back only on the final tick; the readback stalls the GUI thread.
    m_rc->polishItems();
    // beginFrame() reports nothing (void); a dead RHI shows up as the null
    // rhi()/root checks above on the next tick and as a blank readback here.
    m_rc->beginFrame();
    m_rc->sync();
    m_rc->render();
    QRhiReadbackResult rb;
    if (grab) {
        QRhiResourceUpdateBatch *batch = rhi->nextResourceUpdateBatch();
        batch->readBackTexture(m_texture.get(), &rb);
        m_rc->commandBuffer()->resourceUpdate(batch);
    }
    m_rc->endFrame();

    if (!grab)
        return; // still warming up

    m_settle->stop();

    QImage img;
    if (!rb.data.isEmpty()) {
        QImage wrap(reinterpret_cast<const uchar *>(rb.data.constData()),
                    rb.pixelSize.width(), rb.pixelSize.height(),
                    QImage::Format_RGBA8888_Premultiplied);
        img = rhi->isYUpInFramebuffer() ? wrap.flipped(Qt::Vertical) : wrap.copy();
        // Un-premultiply so the saved webp's alpha edges stay clean
        // (premultiplied RGB darkens partially-transparent pixels once
        // composited again).
        img = img.convertToFormat(QImage::Format_ARGB32);
    }
    finishJob(img, false);
}

void WatchfacePreviewRenderer::finishJob(const QImage &frame, bool rendererDied)
{
    const QString name = faceNameFromUrl(m_current.url);

    // Center-crop to square and gate on content: a face that has not painted
    // yet reads back near-transparent, and saving that would clobber the
    // existing preview/gallery substitute with a blank. Never save a blank;
    // requeue it (absorbs load races) with a longer warm-up.
    double opaque = 0.0;
    QImage square;
    if (!frame.isNull()) {
        const int side = qMin(frame.width(), frame.height());
        square = frame.copy((frame.width() - side) / 2,
                            (frame.height() - side) / 2, side, side);
        opaque = opaqueFraction(square);
    }

    if (opaque < kMinOpaqueFraction) {
        qCWarning(lcWfPreview).noquote()
            << name << "blank grab (opaque" << QString::number(opaque, 'f', 4)
            << "frames" << m_frames << "attempt" << m_current.attempts
            << (rendererDied ? "renderer-died)" : ")");
        Job job = m_current;
        teardownFace();
        m_busy = false;
        if (job.attempts < kMaxRetries) {
            job.attempts++;
            const int delay = 400 * job.attempts; // linear backoff
            QTimer::singleShot(delay, this, [this, job]() {
                enqueue(job);
                startNext();
            });
        }
        scheduleNext();
        return;
    }

    const QImage scaled = square.scaled(m_current.size, m_current.size,
                                        Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
    const QString dest = previewPathFor(name, m_current.size);
    QDir().mkpath(QFileInfo(dest).absolutePath());
    // Write atomically (temp + rename): the settings side watches this
    // directory and a half-written webp would load broken, blanking the tile
    // it should update.
    QSaveFile file(dest);
    if (file.open(QIODevice::WriteOnly) && scaled.save(&file, "webp") && file.commit()) {
        qCDebug(lcWfPreview).noquote() << name << "saved (opaque"
            << QString::number(opaque, 'f', 4) << "frames" << m_frames << ")";
    } else {
        qCWarning(lcWfPreview).noquote() << name << "webp save failed";
    }

    teardownFace();
    m_busy = false;
    scheduleNext();
}

void WatchfacePreviewRenderer::scheduleNext()
{
    if (m_busy)
        return;
    if (m_queue.isEmpty()) {
        m_idleTeardown->start();
        return;
    }
    // Defer the next queued face so the compositor GUI thread gets idle time
    // between renders; draining the queue back-to-back is what freezes the UI.
    QTimer::singleShot(kYieldBetweenJobs, this, [this]() {
        startNext();
    });
}

void WatchfacePreviewRenderer::teardownFace()
{
    if (m_rootItem) {
        m_rootItem->setParentItem(nullptr);
        m_rootItem->deleteLater();
        m_rootItem = nullptr;
    }
    m_component.reset();
}

void WatchfacePreviewRenderer::teardownGpu()
{
    m_rpDesc.reset();
    m_rt.reset();
    m_ds.reset();
    m_texture.reset();
    m_targetSize = QSize();
    if (m_rc)
        m_rc->invalidate();
    m_window.reset();
    m_rc.reset();
    m_engine.reset();
}
