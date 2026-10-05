/*
 * SPDX-FileCopyrightText: 2026 Timo Könnecke <github.com/moWerk>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef WATCHFACERELOADER_H
#define WATCHFACERELOADER_H

#include <QDateTime>
#include <QFileSystemWatcher>
#include <QHash>
#include <QObject>
#include <QString>
#include <QTimer>

class QQmlEngine;

/*!
 * \brief Reloads watchfaces and their bundled fonts added at runtime.
 *
 * Two Qt caches keep a just-installed watchface from showing without a restart:
 *
 * 1. QQmlTypeLoader reads a directory's listing the first time it resolves a
 *    file there and then reuses that cached listing for the life of the process,
 *    with no invalidation. A watchface downloaded into the user watchface folder
 *    after that first read is invisible to the loader ("File name case mismatch")
 *    until the component cache is dropped.
 * 2. QFontDatabase is populated from fontconfig once at startup. A font a
 *    watchface bundles into the user font folder afterwards is unknown to the
 *    running process, so the watchface renders with a fallback family until the
 *    session is restarted.
 *
 * This watches both folders and routes each change by its path: a watchface
 * change drops the QML component cache; a font change registers new or replaced
 * fonts straight into the running font database with
 * QFontDatabase::addApplicationFont() (no fc-cache, no restart) and reloads only
 * when a font actually arrived. The user fonts are also registered at startup:
 * they exist only in the user folder, and fontconfig knows them only after an
 * fc-cache run nothing guarantees has happened (a fresh install never ran one),
 * so relying on fontconfig would leave every store face on fallback fonts after
 * a session restart.
 */
class WatchfaceReloader : public QObject
{
    Q_OBJECT
public:
    explicit WatchfaceReloader(QQmlEngine *engine, QObject *parent = nullptr);

signals:
    //! Emitted after the cache is cleared so QML can re-trigger the watchface
    //! loader against the freshly re-read directory.
    void reloadNeeded();

private slots:
    void onDirectoryChanged(const QString &path);

private:
    //! One pass over the user font folder: register fonts not yet in the
    //! running database, re-register files replaced in place (same path, new
    //! size or mtime), and drop database entries for files that vanished.
    //! Returns how many fonts newly registered; sets m_pendingFonts to the
    //! number present on disk but not (yet) loadable.
    int scanFonts();

    void clearCacheAndReload();

    struct FontRecord {
        int id = -1;
        qint64 size = 0;
        QDateTime mtime;
    };

    QQmlEngine *m_engine;
    QFileSystemWatcher m_watcher;
    QTimer m_settleTimer;
    int m_settleTries = 0;
    int m_pendingFonts = 0;
    QString m_watchfaceDir;
    QString m_fontsDir;
    QHash<QString, FontRecord> m_fonts;
    //! Load attempts per path; a file that keeps failing (corrupt or an
    //! unsupported format) stops being retried once its budget is spent, so it
    //! cannot re-arm the settle chain on every later folder change.
    QHash<QString, int> m_attempts;
};

#endif // WATCHFACERELOADER_H
