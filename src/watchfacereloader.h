/*
 * SPDX-FileCopyrightText: 2026 Timo Könnecke <github.com/moWerk>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef WATCHFACERELOADER_H
#define WATCHFACERELOADER_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QString>

class QQmlEngine;

/*!
 * \brief Drops the QML component cache when a watchface is added at runtime.
 *
 * Qt's QQmlTypeLoader reads a directory's listing the first time it resolves a
 * file there and then reuses that cached listing for the life of the process,
 * with no invalidation. A watchface downloaded into the user watchface folder
 * after that first read is therefore invisible to the loader ("File name case
 * mismatch") until the cache is dropped. This watches the folder and clears the
 * component cache when it changes so newly installed watchfaces load live,
 * without restarting the launcher.
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
    QQmlEngine *m_engine;
    QFileSystemWatcher m_watcher;
    QString m_dir;
};

#endif // WATCHFACERELOADER_H
