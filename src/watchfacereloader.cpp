/*
 * SPDX-FileCopyrightText: 2026 Timo Könnecke <github.com/moWerk>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "watchfacereloader.h"

#include <QQmlEngine>
#include <QDir>
#include <QStandardPaths>

WatchfaceReloader::WatchfaceReloader(QQmlEngine *engine, QObject *parent)
    : QObject(parent)
    , m_engine(engine)
{
    // Same location the settings watchface store installs into.
    m_dir = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
            + QStringLiteral("/asteroid-launcher/watchfaces");
    QDir().mkpath(m_dir);
    m_watcher.addPath(m_dir);
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged,
            this, &WatchfaceReloader::onDirectoryChanged);
}

void WatchfaceReloader::onDirectoryChanged(const QString &)
{
    if (!m_engine)
        return;

    // Clearing the component cache forces the next QML load to re-read the
    // directory, so a just-installed watchface becomes loadable immediately.
    m_engine->clearComponentCache();
    emit reloadNeeded();

    // QFileSystemWatcher drops a path that momentarily disappears (some tools
    // replace directories atomically); re-add it so we keep watching.
    if (!m_watcher.directories().contains(m_dir) && QDir(m_dir).exists())
        m_watcher.addPath(m_dir);
}
