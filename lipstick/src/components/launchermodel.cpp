
// This file is part of lipstick, a QML desktop library
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License version 2.1 as published by the Free Software Foundation
// and appearing in the file LICENSE.LGPL included in the packaging
// of this file.
//
// This code is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>

#include <QDir>
#include <QFileSystemWatcher>
#include <QDBusConnection>
#include <QDebug>
#include <QFile>
#include <QSettings>
#include <QStandardPaths>

#include "launcheritem.h"
#include "launchermodel.h"


#define LAUNCHER_APPS_PATH "/usr/share/applications/"

// Make sure to also update this in the .spec file, so it gets
// created whenever lipstick is installed, otherwise monitoring
// will fail and newly-installed icons will not be detected
#define LAUNCHER_ICONS_PATH "/usr/share/icons/hicolor/86x86/apps/"

static inline bool isDesktopFile(const QStringList &applicationPaths, const QString &filename)
{
    if (!filename.endsWith(QStringLiteral(".desktop"))) {
        return false;
    } else foreach (const QString &path, applicationPaths) {
        if (filename.startsWith(path)) {
            return true;
        }
    }
    return false;
}

static inline bool isIconFile(const QString &filename)
{
    // TODO: Possibly support other file types
    return filename.startsWith(QLatin1Char('/')) && filename.endsWith(".png");
}

static inline QString iconIdFromFilename(const QString &filename)
{
    int start = filename.lastIndexOf('/') + 1;
    int end = filename.lastIndexOf('.');

    if (start == -1 || end == -1) {
        // something's fishy..
        return QString();
    }

    return filename.mid(start, end - start);
}

static inline QString filenameFromIconId(const QString &filename, const QString &path)
{
    return QString("%1%2%3").arg(path).arg(filename).arg(".png");
}

static inline bool isVisibleDesktopFile(const QString &filename)
{
    LauncherItem item(filename);

    return item.isValid() && item.shouldDisplay();
}

static QStringList defaultDirectories()
{
    QString userLocalAppsPath = QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation);
    QDir userLocalLauncherDir(userLocalAppsPath);
    if (!userLocalLauncherDir.exists()) {
        userLocalLauncherDir.mkpath(userLocalAppsPath);
    }

    return QStringList() << QStringLiteral(LAUNCHER_APPS_PATH) << userLocalAppsPath;
}

Q_GLOBAL_STATIC(LauncherDBus, _launcherDBus);

LauncherModel::LauncherModel(QObject *parent) :
    QObjectListModel(parent),
    _directories(defaultDirectories()),
    _iconDirectories(LAUNCHER_ICONS_PATH),
    _fileSystemWatcher(),
    _launcherSettings("nemomobile", "lipstick"),
    _globalSettings("/usr/share/lipstick/lipstick.conf", QSettings::IniFormat),
    _launcherOrderPrefix(QStringLiteral("LauncherOrder/")),
    _initialized(false)
{
    initialize();
}

LauncherModel::LauncherModel(InitializationMode, QObject *parent) :
    QObjectListModel(parent),
    _directories(defaultDirectories()),
    _iconDirectories(LAUNCHER_ICONS_PATH),
    _fileSystemWatcher(),
    _launcherSettings("nemomobile", "lipstick"),
    _globalSettings("/usr/share/lipstick/lipstick.conf", QSettings::IniFormat),
    _launcherOrderPrefix(QStringLiteral("LauncherOrder/")),
    _initialized(false)
{
}

void LauncherModel::initialize()
{
    if (_initialized)
        return;
    _initialized = true;

    _launcherDBus()->registerModel(this);

    QStringList iconDirectories = _iconDirectories;
    if (!iconDirectories.contains(LAUNCHER_ICONS_PATH))
        iconDirectories << LAUNCHER_ICONS_PATH;

    _launcherMonitor.setDirectories(_directories);
    _launcherMonitor.setIconDirectories(iconDirectories);

    // Set up the monitor for icon and desktop file changes
    connect(&_launcherMonitor, SIGNAL(filesUpdated(const QStringList &, const QStringList &, const QStringList &)),
            this, SLOT(onFilesUpdated(const QStringList &, const QStringList &, const QStringList &)));

    // Start monitoring
    _launcherMonitor.start();

    // Save order of icons when model is changed
    connect(this, SIGNAL(rowsMoved(const QModelIndex&,int,int,const QModelIndex&,int)), this, SLOT(savePositions()));

    // Watch for changes to the item order settings file
    _fileSystemWatcher.addPath(_launcherSettings.fileName());
    connect(&_fileSystemWatcher, SIGNAL(fileChanged(QString)), this, SLOT(monitoredFileChanged(QString)));
}

LauncherModel::~LauncherModel()
{
    _launcherDBus()->deregisterModel(this);
}

void LauncherModel::onFilesUpdated(const QStringList &added,
        const QStringList &modified, const QStringList &removed)
{
    QStringList modifiedAndNeedUpdating = modified;

    // First, remove all removed launcher items before adding new ones
    foreach (const QString &filename, removed) {
        if (isDesktopFile(_directories, filename)) {
            // Desktop file has been removed - remove launcher
            LauncherItem *item = itemInModel(filename);
            if (item != NULL) {
                LAUNCHER_DEBUG("Removing launcher item:" << filename);
                removeItem(item);
            }
        } else if (isIconFile(filename)) {
            // Icons has been removed - find item and clear its icon path
            updateItemsWithIcon(filename, false);
        }
    }

    foreach (const QString &filename, added) {
        if (isDesktopFile(_directories, filename)) {
            // New desktop file appeared - add launcher
            LauncherItem *item = itemInModel(filename);

            if (item == NULL) {
                LAUNCHER_DEBUG("Trying to add launcher item:" << filename);
                item = addItemIfValid(filename);

                if (item != NULL) {
                    // Try to look up an already-installed icon in the icons directory
                    foreach (const QString &iconPath, _launcherMonitor.iconDirectories()) {
                        QString iconname = filenameFromIconId(item->getOriginalIconId(), iconPath);
                        if (QFile(iconname).exists()) {
                            LAUNCHER_DEBUG("Loading existing icon:" << iconname);
                            updateItemsWithIcon(iconname, true);
                            break;
                        }
                    }
                }
            } else {
                // A .desktop file reported as new while already in the model:
                // treat it as modified so its entry gets refreshed below
                modifiedAndNeedUpdating << filename;
            }
        } else if (isIconFile(filename)) {
            // Icons has been added - find item and update its icon path
            updateItemsWithIcon(filename, true);
        }
    }

    foreach (const QString &filename, modifiedAndNeedUpdating) {
        if (isDesktopFile(_directories, filename)) {
            // Desktop file has been updated - update launcher
            LauncherItem *item = itemInModel(filename);
            if (item != NULL) {
                bool isValid = item->isStillValid() && item->shouldDisplay();
                if (!isValid) {
                    // File has changed in such a way (e.g. Hidden=true) that
                    // it now should become invisible again
                    removeItem(item);
                } else {
                    // File has been updated and is still valid; check if we
                    // might need to auto-update the icon file
                    if (item->iconFilename().isEmpty()) {
                        foreach (const QString &iconPath, _launcherMonitor.iconDirectories()) {
                            QString filename = filenameFromIconId(item->getOriginalIconId(), iconPath);
                            LAUNCHER_DEBUG("Desktop file changed, checking for:" << filename);
                            if (QFile(filename).exists()) {
                                updateItemsWithIcon(filename, true);
                                break;
                            }
                        }
                    }
                }
            } else {
                // No item yet (maybe it had Hidden=true before), try to see if
                // we should show the item now
                addItemIfValid(filename);
            }
        } else if (isIconFile(filename)) {
            // Icons has been updated - find item and update its icon path
            updateItemsWithIcon(filename, true);
        }
    }

    reorderItems();
    savePositions();
}

void LauncherModel::updateItemsWithIcon(const QString &filename, bool existing)
{
    QString iconId = iconIdFromFilename(filename);

    LAUNCHER_DEBUG("updateItemsWithIcon: filename=" << filename << ", existing=" << existing << ", id=" << iconId);

    foreach (LauncherItem *item, *getList<LauncherItem>()) {
        const QString &currentId = item->getOriginalIconId();
        if (currentId.isEmpty()) {
            continue;
        }

        if (!existing && filename == item->iconFilename()) {
            // File is currently used as icon, but has been removed
            LAUNCHER_DEBUG("Icon vanished, removing:" << filename);
            item->setIconFilename("");
        } else if (existing) {
            if ((filename == currentId) /* absolute file path in .desktop file */ ||
                    (iconId == currentId) /* icon id matches */) {
                LAUNCHER_DEBUG("Icon was added or updated:" << filename);
                item->setIconFilename(filename);
            }
        }
    }
}

void LauncherModel::monitoredFileChanged(const QString &changedPath)
{
    if (changedPath == _launcherSettings.fileName()) {
        loadPositions();
    } else {
        qWarning() << "Unknown monitored file in LauncherModel:" << changedPath;
    }
}

void LauncherModel::loadPositions()
{
    _launcherSettings.sync();
    reorderItems();
}

void LauncherModel::reorderItems()
{
    QMap<int, LauncherItem *> itemsWithPositions;
    QMap<QString, LauncherItem *> itemsWithoutPositions;

    QList<LauncherItem *> *currentLauncherList = getList<LauncherItem>();
    foreach (LauncherItem *item, *currentLauncherList) {
        QVariant pos = launcherPos(item->filePath());

        if (pos.isValid()) {
            int gridPos = pos.toInt();
            itemsWithPositions.insert(gridPos, item);
        } else {
            itemsWithoutPositions.insert(item->title(), item);
        }
    }

    QList<LauncherItem *> reordered;
    {
        // Order the positioned items into contiguous order
        QMap<int, LauncherItem *>::const_iterator it = itemsWithPositions.constBegin(), end = itemsWithPositions.constEnd();
        for ( ; it != end; ++it) {
            LAUNCHER_DEBUG("Planned move of" << it.value()->title() << "to" << reordered.count());
            reordered.append(it.value());
        }
    }
    {
        // Append the un-positioned items in sorted-by-title order
        QMap<QString, LauncherItem *>::const_iterator it = itemsWithoutPositions.constBegin(), end = itemsWithoutPositions.constEnd();
        for ( ; it != end; ++it) {
            LAUNCHER_DEBUG("Planned move of" << it.value()->title() << "to" << reordered.count());
            reordered.append(it.value());
        }
    }

    for (int gridPos = 0; gridPos < reordered.count(); ++gridPos) {
        LauncherItem *item = reordered.at(gridPos);
        LAUNCHER_DEBUG("Moving" << item->filePath() << "to" << gridPos);

        if (gridPos < 0 || gridPos >= itemCount()) {
            LAUNCHER_DEBUG("Invalid planned position for" << item->filePath());
            continue;
        }

        int currentPos = indexOf(item);
        Q_ASSERT(currentPos >= 0);
        if (currentPos == -1)
            continue;

        if (gridPos == currentPos)
            continue;

        move(currentPos, gridPos);
    }
}

QStringList LauncherModel::directories() const
{
    return _directories;
}

static QStringList suffixDirectories(const QStringList &directories)
{
    QStringList copy = directories;
    for (int i = 0; i < directories.count(); ++i) {
        if (!directories.at(i).endsWith(QLatin1Char('/'))) {
            copy.replace(i, directories.at(i) + QLatin1Char('/'));
        }
    }
    return copy;
}

void LauncherModel::setDirectories(QStringList newDirectories)
{
    newDirectories = suffixDirectories(newDirectories);

    if (_directories != newDirectories) {
        _directories = newDirectories;
        emit directoriesChanged();

        if (_initialized) {
            _launcherMonitor.setDirectories(_directories);
        }
    }
}

QStringList LauncherModel::iconDirectories() const
{
    return _iconDirectories;
}

void LauncherModel::setIconDirectories(QStringList newDirectories)
{
    newDirectories = suffixDirectories(newDirectories);

    if (_iconDirectories != newDirectories) {
        _iconDirectories = newDirectories;
        emit iconDirectoriesChanged();

        if (_initialized) {
            newDirectories = _iconDirectories;
            if (!newDirectories.contains(LAUNCHER_ICONS_PATH))
                newDirectories << LAUNCHER_ICONS_PATH;
            _launcherMonitor.setIconDirectories(newDirectories);
        }
    }
}

QStringList LauncherModel::categories() const
{
    return _categories;
}

void LauncherModel::setCategories(const QStringList &categories)
{
    if (_categories != categories) {
        _categories = categories;
        emit categoriesChanged();

        if (_initialized) {
            // Force a complete rebuild of the model.
            _launcherMonitor.setDirectories(QStringList());
            _launcherMonitor.setDirectories(_directories);
        }
    }
}

QString LauncherModel::scope() const
{
    return _scope;
}

void LauncherModel::setScope(const QString &scope)
{
    if (_scope != scope) {
        _scope = scope;
        _launcherOrderPrefix = !_scope.isEmpty()
                ? scope + QStringLiteral("/LauncherOrder/")
                : QStringLiteral("LauncherOrder/");
        emit scopeChanged();

        if (_initialized) {
            loadPositions();
        }
    }
}

void LauncherModel::notifyLaunching(const QString &desktopFile)
{
    LauncherItem *item = itemInModel(desktopFile);
    if (item) {
        item->setIsLaunching(true);
        emit notifyLaunching(item);
    } else {
        qWarning("No launcher item found for \"%s\".", qPrintable(desktopFile));
    }
}

void LauncherModel::savePositions()
{
    _fileSystemWatcher.removePath(_launcherSettings.fileName());

    _launcherSettings.remove(_launcherOrderPrefix.left(_launcherOrderPrefix.count() - 1));
    QList<LauncherItem *> *currentLauncherList = getList<LauncherItem>();

    int pos = 0;
    foreach (LauncherItem *item, *currentLauncherList) {
        _launcherSettings.setValue(_launcherOrderPrefix + item->filePath(), pos);
        ++pos;
    }

    _launcherSettings.sync();
    _fileSystemWatcher.addPath(_launcherSettings.fileName());
}

int LauncherModel::findItem(const QString &path, LauncherItem **item)
{
    QList<LauncherItem*> *list = getList<LauncherItem>();
    for (int i = 0; i < list->count(); ++i) {
        LauncherItem *listItem = list->at(i);
        if (listItem->filePath() == path || listItem->filename() == path) {
            if (item)
                *item = listItem;
            return i;
        }
    }

    if (item)
        *item = 0;

    return -1;
}

LauncherItem *LauncherModel::itemInModel(const QString &path)
{
    LauncherItem *result = 0;
    (void)findItem(path, &result);
    return result;
}

int LauncherModel::indexInModel(const QString &path)
{
    return findItem(path, 0);
}

QVariant LauncherModel::launcherPos(const QString &path)
{
    QString key = _launcherOrderPrefix + path;

    if (_launcherSettings.contains(key)) {
        return _launcherSettings.value(key);
    }

    // fall back to vendor configuration if the user hasn't specified a location
    return _globalSettings.value(key);
}

LauncherItem *LauncherModel::addItemIfValid(const QString &path)
{
    LAUNCHER_DEBUG("Creating LauncherItem for desktop entry" << path);
    LauncherItem *item = new LauncherItem(path, this);

    bool isValid = item->isValid();
    bool shouldDisplay = item->shouldDisplay() && _categories.isEmpty();
    foreach (const QString &category, item->desktopCategories()) {
        if (_categories.contains(category)) {
            shouldDisplay = true;
            break;
        }
    }
    if (isValid && shouldDisplay) {
        addItem(item);
    } else {
        LAUNCHER_DEBUG("Item" << path << (!isValid ? "is not valid" : "should not be displayed"));
        delete item;
        item = NULL;
    }

    return item;
}
