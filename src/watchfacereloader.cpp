/*
 * SPDX-FileCopyrightText: 2026 Timo Könnecke <github.com/moWerk>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "watchfacereloader.h"

#include <QQmlEngine>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QFontDatabase>
#include <QStandardPaths>

namespace {
constexpr int kSettleIntervalMs = 800;
constexpr int kMaxSettleTries = 6;
constexpr int kMaxLoadAttempts = 8;
}

WatchfaceReloader::WatchfaceReloader(QQmlEngine *engine, QObject *parent)
    : QObject(parent)
    , m_engine(engine)
{
    // Same locations the settings watchface store installs into.
    m_watchfaceDir = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
            + QStringLiteral("/asteroid-launcher/watchfaces");
    m_fontsDir = QStandardPaths::writableLocation(QStandardPaths::HomeLocation)
            + QStringLiteral("/.fonts");

    QDir().mkpath(m_watchfaceDir);
    QDir().mkpath(m_fontsDir);
    m_watcher.addPath(m_watchfaceDir);
    m_watcher.addPath(m_fontsDir);

    // Register everything already in the user font folder. These fonts exist
    // nowhere else, and fontconfig only knows them after an fc-cache run that
    // nothing guarantees has happened — on a freshly flashed device it never
    // has — so store faces would render with fallback fonts after any session
    // restart. Registering an already-known family is harmless.
    scanFonts();

    connect(&m_watcher, &QFileSystemWatcher::directoryChanged,
            this, &WatchfaceReloader::onDirectoryChanged);

    // A font pushed by an external writer (adb, scp) may still be mid-write
    // when the folder-changed signal fires, so addApplicationFont reads a
    // truncated file. Re-scan a short moment later, re-arming while a font on
    // disk remains unloaded, so it is registered and applied live once its
    // write finishes. (Store installs write to the final path in one shot, so
    // in practice this chain serves the external writers.)
    m_settleTimer.setSingleShot(true);
    m_settleTimer.setInterval(kSettleIntervalMs);
    connect(&m_settleTimer, &QTimer::timeout, this, [this]() {
        if (scanFonts() > 0)
            clearCacheAndReload();
        if (m_pendingFonts > 0 && ++m_settleTries < kMaxSettleTries)
            m_settleTimer.start();
        else
            m_settleTries = 0;
    });
}

int WatchfaceReloader::scanFonts()
{
    static const QStringList kFontFilters{
        QStringLiteral("*.ttf"), QStringLiteral("*.otf"), QStringLiteral("*.ttc")};

    int added = 0;
    m_pendingFonts = 0;
    const QFileInfoList files =
        QDir(m_fontsDir).entryInfoList(kFontFilters, QDir::Files, QDir::NoSort);
    for (const QFileInfo &fi : files) {
        const QString path = fi.absoluteFilePath();
        const auto it = m_fonts.constFind(path);
        if (it != m_fonts.constEnd()) {
            if (it->size == fi.size() && it->mtime == fi.lastModified())
                continue;
            // Replaced in place (store re-download, script push): the database
            // still serves the old file's glyphs under this family. Drop and
            // re-register below.
            QFontDatabase::removeApplicationFont(it->id);
            m_fonts.remove(path);
            m_attempts.remove(path);
        }
        if (m_attempts.value(path, 0) >= kMaxLoadAttempts)
            continue;
        const int id = QFontDatabase::addApplicationFont(path);
        if (id != -1) {
            m_fonts.insert(path, { id, fi.size(), fi.lastModified() });
            m_attempts.remove(path);
            ++added;
        } else {
            // Truncated mid-write or genuinely broken; the settle chain
            // retries until the attempt budget rules it broken.
            ++m_attempts[path];
            ++m_pendingFonts;
        }
    }

    // Files that vanished release their database entry, so an uninstalled
    // face's font does not linger for the life of the process.
    for (auto rec = m_fonts.begin(); rec != m_fonts.end();) {
        if (!QFile::exists(rec.key())) {
            QFontDatabase::removeApplicationFont(rec.value().id);
            rec = m_fonts.erase(rec);
        } else {
            ++rec;
        }
    }
    return added;
}

void WatchfaceReloader::clearCacheAndReload()
{
    if (!m_engine)
        return;
    // Clearing the component cache forces the next QML load to re-read the
    // directory, so a just-installed watchface becomes loadable immediately.
    m_engine->clearComponentCache();
    emit reloadNeeded();
}

void WatchfaceReloader::onDirectoryChanged(const QString &path)
{
    // Route by folder: dropping the component cache tears down and reloads the
    // active watchface, so unrelated font-folder churn must not trigger it,
    // and a watchface install must not pay a font scan.
    if (path == m_fontsDir) {
        if (scanFonts() > 0)
            clearCacheAndReload();
        if (m_pendingFonts > 0) {
            m_settleTries = 0;
            m_settleTimer.start();
        }
    } else {
        clearCacheAndReload();
    }

    // QFileSystemWatcher drops a path that momentarily disappears (some tools
    // replace directories atomically); re-create and re-add so we keep
    // watching.
    const QStringList watched = m_watcher.directories();
    for (const QString &dir : {m_watchfaceDir, m_fontsDir}) {
        if (!watched.contains(dir)) {
            QDir().mkpath(dir);
            m_watcher.addPath(dir);
        }
    }
}
