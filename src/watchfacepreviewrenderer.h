/*
 * SPDX-FileCopyrightText: 2026 Timo Könnecke <github.com/moWerk>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef WATCHFACEPREVIEWRENDERER_H
#define WATCHFACEPREVIEWRENDERER_H

#include <QObject>
#include <QUrl>
#include <QSize>
#include <QQueue>
#include <memory>

class QQmlEngine;
class QQmlComponent;
class QQuickRenderControl;
class QQuickWindow;
class QQuickItem;
class QRhiTexture;
class QRhiRenderBuffer;
class QRhiTextureRenderTarget;
class QRhiRenderPassDescriptor;
class QTimer;
class QImage;

/*!
 * \brief Renders a watchface QML offscreen and saves a square preview webp.
 *
 * The store needs a still preview of every watchface at the device's list
 * size. Grabbing the live homescreen is unreliable: it is occluded while the
 * store is open (its render loop is throttled) and reflects transient state
 * (nightstand, charge ring). Instead this renders each face into its own
 * offscreen QRhi render target via QQuickRenderControl, independent of what is
 * on screen. The face renders at the real screen size, so layouts derived from
 * Screen geometry come out right and thin strokes survive, then the square
 * center crop is downscaled once to the preview size and saved as webp.
 *
 * A request whose preview on disk is already newer than the face's QML is
 * skipped, so re-activations and boots cost nothing. The offscreen machinery
 * (a second QML engine and render stack) exists only while jobs are running
 * and is torn down after a short idle, since activations are rare events in
 * the life of the launcher process.
 */
class WatchfacePreviewRenderer : public QObject
{
    Q_OBJECT
public:
    explicit WatchfacePreviewRenderer(QObject *parent = nullptr);
    ~WatchfacePreviewRenderer() override;

    /*!
     * \brief Queue \a faceUrl to be rendered and saved as a square preview of
     * \a size px. Skips work the disk already holds, coalesces duplicates,
     * cancels a stale in-flight render when a different face arrives, and
     * renders one face at a time so a burst of activations cannot stall the
     * process.
     */
    Q_INVOKABLE void requestPreview(const QUrl &faceUrl, int size);

private:
    struct Job { QUrl url; int size = 0; int attempts = 0; };

    void enqueue(const Job &job);
    bool ensureRhi();
    bool ensureTarget(const QSize &pixelSize);
    void startNext();
    // One warm-up/render tick; the last tick reads back and hands to finishJob.
    void renderTick();
    // Crop, gate on content, and either save the webp or requeue a blank grab.
    void finishJob(const QImage &frame, bool rendererDied);
    // Dequeue the next face after a short idle yield (keeps the UI responsive).
    void scheduleNext();
    void teardownFace();
    // Release the render target, window, render control and engine. The next
    // request rebuilds them; ensureRhi()/ensureTarget() make that cheap to
    // express and the idle timer makes it rare.
    void teardownGpu();

    std::unique_ptr<QQuickRenderControl>      m_rc;
    std::unique_ptr<QQuickWindow>             m_window;
    std::unique_ptr<QQmlEngine>               m_engine;
    std::unique_ptr<QQmlComponent>            m_component;
    QQuickItem                               *m_rootItem = nullptr;

    std::unique_ptr<QRhiTexture>              m_texture;
    std::unique_ptr<QRhiRenderBuffer>         m_ds;
    std::unique_ptr<QRhiTextureRenderTarget>  m_rt;
    std::unique_ptr<QRhiRenderPassDescriptor> m_rpDesc;
    QSize                                     m_targetSize;

    QQueue<Job> m_queue;
    Job         m_current;
    bool        m_busy = false;
    QTimer     *m_settle = nullptr;       // drives the render/warm-up ticks
    QTimer     *m_idleTeardown = nullptr; // releases the GPU stack after idle
    int         m_frames = 0;             // frames rendered this attempt
    int         m_settleTicks = 0;        // warm-up ticks before readback (grows on retry)
};

#endif // WATCHFACEPREVIEWRENDERER_H
