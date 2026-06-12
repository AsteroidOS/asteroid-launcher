/***************************************************************************
**
** Copyright (C) 2012 Jolla Ltd.
** Contact: Robin Burchell <robin.burchell@jollamobile.com>
**
** This file is part of lipstick.
**
** This library is free software; you can redistribute it and/or
** modify it under the terms of the GNU Lesser General Public
** License version 2.1 as published by the Free Software Foundation
** and appearing in the file LICENSE.LGPL included in the packaging
** of this file.
**
****************************************************************************/

#include <QCoreApplication>
#include <QDebug>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlTableModel>
#include <mremoteaction.h>
#include <mdesktopentry.h>
#include <sys/statfs.h>
#include <limits>
#include "androidprioritystore.h"
#include "categorydefinitionstore.h"
#include "notificationmanageradaptor.h"
#include "notificationmanager.h"

// Define this if you'd like to see debug messages from the notification manager
#ifdef DEBUG_NOTIFICATIONS
#define NOTIFICATIONS_DEBUG(things) qDebug() << Q_FUNC_INFO << things
#else
#define NOTIFICATIONS_DEBUG(things)
#endif

//! The android priority store path
static const char *ANDROID_PRIORITY_DEFINITION_PATH = "/usr/share/lipstick/androidnotificationpriorities";

//! The android bridge process name
static const char *ANDROID_BRIDGE_PROCESS = "alien_bridge_server";

//! The category definitions directory
static const char *CATEGORY_DEFINITION_FILE_DIRECTORY = "/usr/share/lipstick/notificationcategories";

//! The number configuration files to load into the event type store.
static const uint MAX_CATEGORY_DEFINITION_FILES = 100;

//! Path of the privileged storage directory relative to the home directory
static const char *PRIVILEGED_DATA_PATH= "/.local/share/system/privileged";

//! Path to probe for desktop entries
static const char *DESKTOP_ENTRY_PATH= "/usr/share/applications/";

//! Minimum amount of disk space needed for the notification database in kilobytes
static const uint MINIMUM_FREE_SPACE_NEEDED_IN_KB = 1024;

const char *NotificationManager::HINT_URGENCY = "urgency";
const char *NotificationManager::HINT_CATEGORY = "category";
const char *NotificationManager::HINT_TRANSIENT = "transient";
const char *NotificationManager::HINT_RESIDENT = "resident";
const char *NotificationManager::HINT_IMAGE_PATH = "image-path";
const char *NotificationManager::HINT_ICON = "x-nemo-icon";
const char *NotificationManager::HINT_ITEM_COUNT = "x-nemo-item-count";
const char *NotificationManager::HINT_PRIORITY = "x-nemo-priority";
const char *NotificationManager::HINT_TIMESTAMP = "x-nemo-timestamp";
const char *NotificationManager::HINT_PREVIEW_ICON = "x-nemo-preview-icon";
const char *NotificationManager::HINT_PREVIEW_BODY = "x-nemo-preview-body";
const char *NotificationManager::HINT_PREVIEW_SUMMARY = "x-nemo-preview-summary";
const char *NotificationManager::HINT_REMOTE_ACTION_PREFIX = "x-nemo-remote-action-";
const char *NotificationManager::HINT_REMOTE_ACTION_ICON_PREFIX = "x-nemo-remote-action-icon-";
const char *NotificationManager::HINT_USER_REMOVABLE = "x-nemo-user-removable";
const char *NotificationManager::HINT_USER_CLOSEABLE = "x-nemo-user-closeable";
const char *NotificationManager::HINT_FEEDBACK = "x-nemo-feedback";
const char *NotificationManager::HINT_FEEDBACK_SUPPRESSED = "x-nemo-feedback-suppressed";
const char *NotificationManager::HINT_HIDDEN = "x-nemo-hidden";
const char *NotificationManager::HINT_DISPLAY_ON = "x-nemo-display-on";
const char *NotificationManager::HINT_LED_DISABLED_WITHOUT_BODY_AND_SUMMARY = "x-nemo-led-disabled-without-body-and-summary";
const char *NotificationManager::HINT_ORIGIN = "x-nemo-origin";
const char *NotificationManager::HINT_ORIGIN_PACKAGE = "x-nemo-origin-package";
const char *NotificationManager::HINT_OWNER = "x-nemo-owner";
const char *NotificationManager::HINT_MAX_CONTENT_LINES = "x-nemo-max-content-lines";
const char *NotificationManager::HINT_RESTORED = "x-nemo-restored";

// Exported for unit test:
int MaxNotificationRestoreCount = 1000;

namespace {

const int DefaultNotificationPriority = 50;

const int CommitDelay = 10 * 1000;
const int PublicationDelay = 1000;

QPair<QString, QString> processProperties(uint pid)
{
    // Cache resolution of process name to properties:
    static QHash<QString, QPair<QString, QString> > nameProperties;

    QPair<QString, QString> rv;

    if (pid == QCoreApplication::applicationPid()) {
        // This notification comes from our process
        rv.first = QCoreApplication::applicationName();
    } else if (pid > 1) {
        const QString procFilename(QString::fromLatin1("/proc/%1/cmdline").arg(QString::number(pid)));
        QFile procFile(procFilename);
        if (procFile.open(QIODevice::ReadOnly)) {
            const QByteArray cmdLine = procFile.readAll();
            const QString processName = QString::fromUtf8(cmdLine.left(cmdLine.indexOf('\0')));
            if (!processName.isEmpty()) {
                const QString basename(QFileInfo(processName).fileName());
                if (!basename.isEmpty()) {
                    QHash<QString, QPair<QString, QString> >::iterator it = nameProperties.find(basename);
                    if (it == nameProperties.end()) {
                        // Look up the desktop entry for this process name
                        MDesktopEntry desktopEntry(DESKTOP_ENTRY_PATH + basename + ".desktop");
                        if (desktopEntry.isValid()) {
                            it = nameProperties.insert(basename, qMakePair(desktopEntry.name(), desktopEntry.icon()));
                        } else {
                            qWarning() << "No desktop entry for process name:" << processName;
                            // Fallback to the basename for application name
                            it = nameProperties.insert(basename, qMakePair(basename, QString()));
                        }
                    }
                    if (it != nameProperties.end()) {
                        rv.first = it->first;
                        rv.second = it->second;
                    }
                }
            }
        } else {
            qWarning() << "Unable to retrieve command line for pid:" << pid;
        }
    }

    return rv;
}

bool notificationReverseOrder(const LipstickNotification *lhs, const LipstickNotification *rhs)
{
    // Sort least significant notifications first
    return *rhs < *lhs;
}

}

NotificationManager *NotificationManager::instance_ = 0;

NotificationManager *NotificationManager::instance(bool owner)
{
    if (instance_ == 0) {
        instance_ = new NotificationManager(qApp, owner);
    }
    return instance_;
}

NotificationManager::NotificationManager(QObject *parent, bool owner) :
    QObject(parent),
    QDBusContext(),
    previousNotificationID(0),
    categoryDefinitionStore(new CategoryDefinitionStore(CATEGORY_DEFINITION_FILE_DIRECTORY, MAX_CATEGORY_DEFINITION_FILES, this)),
    androidPriorityStore(new AndroidPriorityStore(ANDROID_PRIORITY_DEFINITION_PATH, this)),
    database(new QSqlDatabase),
    committed(true),
    nextExpirationTime(0)
{
    if (owner) {
        qDBusRegisterMetaType<QVariantHash>();
        qDBusRegisterMetaType<LipstickNotification>();
        qDBusRegisterMetaType<NotificationList>();

        new NotificationManagerAdaptor(this);
        QDBusConnection::sessionBus().registerService("org.freedesktop.Notifications");
        QDBusConnection::sessionBus().registerObject("/org/freedesktop/Notifications", this);

        connect(categoryDefinitionStore, SIGNAL(categoryDefinitionUninstalled(QString)), this, SLOT(removeNotificationsWithCategory(QString)));
        connect(categoryDefinitionStore, SIGNAL(categoryDefinitionModified(QString)), this, SLOT(updateNotificationsWithCategory(QString)));

        // Commit the modifications to the database 10 seconds after the last modification so that writing to disk doesn't affect user experience
        databaseCommitTimer.setInterval(CommitDelay);
        databaseCommitTimer.setSingleShot(true);
        connect(&databaseCommitTimer, SIGNAL(timeout()), this, SLOT(commit()));

        expirationTimer.setSingleShot(true);
        connect(&expirationTimer, SIGNAL(timeout()), this, SLOT(expire()));

        modificationTimer.setInterval(PublicationDelay);
        modificationTimer.setSingleShot(true);
        connect(&modificationTimer, SIGNAL(timeout()), this, SLOT(reportModifications()));
    }

    restoreNotifications(owner);
}

NotificationManager::~NotificationManager()
{
    database->commit();
    delete database;
}

LipstickNotification *NotificationManager::notification(uint id) const
{
    return notifications.value(id);
}

QList<uint> NotificationManager::notificationIds() const
{
    return notifications.keys();
}

QStringList NotificationManager::GetCapabilities()
{
    return QStringList() << "body"
                         << "actions"
                         << "persistence"
                         << HINT_ICON
                         << HINT_ITEM_COUNT
                         << HINT_TIMESTAMP
                         << HINT_PREVIEW_ICON
                         << HINT_PREVIEW_BODY
                         << HINT_PREVIEW_SUMMARY
                         << "x-nemo-remote-actions"
                         << HINT_USER_REMOVABLE
                         << HINT_ORIGIN
                         << HINT_MAX_CONTENT_LINES
                         << "x-nemo-get-notifications";
}

uint NotificationManager::Notify(const QString &appName, uint replacesId, const QString &appIcon, const QString &summary, const QString &body, const QStringList &actions, const QVariantHash &hints, int expireTimeout)
{
    NOTIFICATIONS_DEBUG("NOTIFY:" << appName << replacesId << appIcon << summary << body << actions << hints << expireTimeout);
    uint id = replacesId != 0 ? replacesId : nextAvailableNotificationID();

    if (replacesId == 0 || notifications.contains(id)) {
        QVariantHash hints_(hints);

        // Ensure the hints contain a timestamp, and convert to UTC if required
        QString timestamp(hints_.value(HINT_TIMESTAMP).toString());
        if (!timestamp.isEmpty()) {
            QDateTime tsValue(QDateTime::fromString(timestamp, Qt::ISODate));
            if (tsValue.isValid()) {
                if (tsValue.timeSpec() != Qt::UTC) {
                    tsValue = tsValue.toUTC();
                }
                timestamp = tsValue.toString(Qt::ISODate);
            } else {
                timestamp = QString();
            }
        }
        if (timestamp.isEmpty()) {
            timestamp = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
        }
        hints_.insert(HINT_TIMESTAMP, timestamp);

        LipstickNotification *notification = 0;
        if (replacesId == 0) {
            // Create a new notification
            notification = new LipstickNotification(appName, id, appIcon, summary, body, actions, hints_, expireTimeout, this);
            connect(notification, SIGNAL(actionInvoked(QString)), this, SLOT(invokeAction(QString)), Qt::QueuedConnection);
            connect(notification, SIGNAL(removeRequested()), this, SLOT(removeNotificationIfUserRemovable()), Qt::QueuedConnection);
            notifications.insert(id, notification);
        } else {
            // Only replace an existing notification if it really exists
            notification = notifications.value(id);
            notification->setAppName(appName);
            notification->setAppIcon(appIcon);
            notification->setSummary(summary);
            notification->setBody(body);
            notification->setActions(actions);
            notification->setHints(hints_);
            notification->setExpireTimeout(expireTimeout);
        }

        // Apply a category definition, if any
        applyCategoryDefinition(notification);
        hints_ = notification->hints();

        QPair<QString, QString> pidProperties;
        bool androidOrigin(false);
        if (calledFromDBus()) {
            // Look up the properties of the originating process
            const QString callerService(message().service());
            const QDBusReply<uint> pidReply(connection().interface()->servicePid(callerService));
            if (pidReply.isValid()) {
                pidProperties = processProperties(pidReply.value());
                androidOrigin = (pidProperties.first == QString::fromLatin1(ANDROID_BRIDGE_PROCESS));
            }
        }

        if (androidOrigin) {
            // The app icon should also be the nemo icon
            const QString icon(hints_.value(HINT_ICON).toString());
            if (icon.isEmpty()) {
                hints_.insert(HINT_ICON, appIcon);
            }

            // If this notification includes a preview, ensure it has a non-empty body and summary
            const QString previewSummary(hints_.value(HINT_PREVIEW_SUMMARY).toString());
            const QString previewBody(hints_.value(HINT_PREVIEW_BODY).toString());
            if (!previewSummary.isEmpty()) {
                if (previewBody.isEmpty()) {
                    hints_.insert(HINT_PREVIEW_BODY, QStringLiteral(" "));
                }
            }
            if (!previewBody.isEmpty()) {
                if (previewSummary.isEmpty()) {
                    hints_.insert(HINT_PREVIEW_SUMMARY, QStringLiteral(" "));
                }
            }

            // See if this notification has elevated priority and feedback
            AndroidPriorityStore::PriorityDetails priority;
            const QString packageName(hints_.value(HINT_ORIGIN_PACKAGE).toString());
            if (!packageName.isEmpty()) {
                priority = androidPriorityStore->packageDetails(packageName);
            } else {
                priority = androidPriorityStore->appDetails(appName);
            }
            hints_.insert(HINT_PRIORITY, priority.first);
            if (!priority.second.isEmpty()) {
                // Add the appropriate feedback, unless it is specifically suppressed
                if (!notification->hints().value(HINT_FEEDBACK_SUPPRESSED).toBool()) {
                    hints_.insert(HINT_FEEDBACK, priority.second);
                    // Also turn the display on if required
                    hints_.insert(HINT_DISPLAY_ON, true);
                }
            }
        } else {
            if (notification->appName().isEmpty() && !pidProperties.first.isEmpty()) {
                notification->setAppName(pidProperties.first);
            }
            if (notification->appIcon().isEmpty() && !pidProperties.second.isEmpty()) {
                notification->setAppIcon(pidProperties.second);
            }

            // Unspecified priority should result in medium priority to permit low priorities
            if (!hints_.contains(HINT_PRIORITY)) {
                hints_.insert(HINT_PRIORITY, DefaultNotificationPriority);
            }
        }

        notification->setHints(hints_);

        publish(notification, replacesId);
    } else {
        // Return the ID 0 when trying to update a notification which doesn't exist
        id = 0;
    }

    return id;
}

void NotificationManager::DeleteNotification(uint id)
{
    // Remove the notification, its actions and its hints from database
    const QVariantList params(QVariantList() << id);
    execSQL(QString("DELETE FROM notifications WHERE id=?"), params);
    execSQL(QString("DELETE FROM actions WHERE id=?"), params);
    execSQL(QString("DELETE FROM hints WHERE id=?"), params);
    execSQL(QString("DELETE FROM expiration WHERE id=?"), params);
}

void NotificationManager::CloseNotification(uint id, NotificationClosedReason closeReason)
{
    if (notifications.contains(id)) {
        emit NotificationClosed(id, closeReason);

        DeleteNotification(id);

        NOTIFICATIONS_DEBUG("REMOVE:" << id);
        emit notificationRemoved(id);

        // Mark the notification to be destroyed
        removedNotifications.insert(notifications.take(id));
    }
}

void NotificationManager::CloseNotifications(const QList<uint> &ids, NotificationClosedReason closeReason)
{
    QSet<uint> uniqueIds(ids.begin(), ids.end());
    QList<uint> removedIds;

    foreach (uint id, uniqueIds) {
        if (notifications.contains(id)) {
            removedIds.append(id);
            emit NotificationClosed(id, closeReason);

            DeleteNotification(id);
        }
    }

    if (!removedIds.isEmpty()) {
        NOTIFICATIONS_DEBUG("REMOVE:" << removedIds);
        emit notificationsRemoved(removedIds);

        foreach (uint id, removedIds) {
            emit notificationRemoved(id);

            // Mark the notification to be destroyed
            removedNotifications.insert(notifications.take(id));
        }
    }
}

void NotificationManager::MarkNotificationDisplayed(uint id)
{
    if (notifications.contains(id)) {
        const LipstickNotification *notification = notifications.value(id);
        if (notification->hints().value(HINT_TRANSIENT).toBool()) {
            // Remove this notification immediately
            CloseNotification(id, NotificationExpired);
            NOTIFICATIONS_DEBUG("REMOVED transient:" << id);
        } else {
            const int timeout(notification->expireTimeout());
            if (timeout > 0) {
                // Insert the timeout into the expiration table, or leave the existing value if already present
                const qint64 currentTime(QDateTime::currentDateTimeUtc().toMSecsSinceEpoch());
                const qint64 expireAt(currentTime + timeout);
                execSQL(QString("INSERT OR IGNORE INTO expiration(id, expire_at) VALUES(?, ?)"), QVariantList() << id << expireAt);

                if (nextExpirationTime == 0 || (expireAt < nextExpirationTime)) {
                    // This will be the next notification to expire - update the timer
                    nextExpirationTime = expireAt;
                    expirationTimer.start(timeout);
                }

                NOTIFICATIONS_DEBUG("DISPLAYED:" << id << "expiring in:" << timeout);
            }
        }
    }
}

QString NotificationManager::GetServerInformation(QString &name, QString &vendor, QString &version)
{
    name = qApp->applicationName();
    vendor = "Nemo Mobile";
    version = qApp->applicationVersion();
    return QString();
}

NotificationList NotificationManager::GetNotifications(const QString &owner)
{
    QList<LipstickNotification *> notificationList;
    QHash<uint, LipstickNotification *>::const_iterator it = notifications.constBegin(), end = notifications.constEnd();
    for ( ; it != end; ++it) {
        LipstickNotification *notification = it.value();
        if (notification->owner() == owner) {
            notificationList.append(notification);
        }
    }

    return NotificationList(notificationList);
}

uint NotificationManager::nextAvailableNotificationID()
{
    bool idIncreased = false;

    // Try to find an unused ID. Increase the ID at least once but only up to 2^32-1 times.
    for (uint i = 0; i < UINT32_MAX && (!idIncreased || notifications.contains(previousNotificationID)); i++, idIncreased = true) {
        previousNotificationID++;

        if (previousNotificationID == 0) {
            // 0 is not a valid ID so skip it
            previousNotificationID = 1;
        }
    }

    return previousNotificationID;
}

void NotificationManager::removeNotificationsWithCategory(const QString &category)
{
    QList<uint> ids;
    QHash<uint, LipstickNotification *>::const_iterator it = notifications.constBegin(), end = notifications.constEnd();
    for ( ; it != end; ++it) {
        LipstickNotification *notification(it.value());
        if (notification->category() == category) {
            ids.append(it.key());
        }
    }
    CloseNotifications(ids);
}

void NotificationManager::updateNotificationsWithCategory(const QString &category)
{
    QList<LipstickNotification *> categoryNotifications;

    QHash<uint, LipstickNotification *>::const_iterator it = notifications.constBegin(), end = notifications.constEnd();
    for ( ; it != end; ++it) {
        LipstickNotification *notification(it.value());
        if (notification->category() == category) {
            categoryNotifications.append(notification);
        }
    }

    foreach (LipstickNotification *notification, categoryNotifications) {
        // Mark the notification as restored to avoid showing the preview banner again
        QVariantHash hints = notification->hints();
        hints.insert(HINT_RESTORED, true);
        notification->setHints(hints);

        // Update the category properties and re-publish
        applyCategoryDefinition(notification);
        publish(notification, notification->replacesId());
    }
}

QHash<QString, QString> NotificationManager::categoryDefinitionParameters(const QVariantHash &hints) const
{
    return categoryDefinitionStore->categoryParameters(hints.value(HINT_CATEGORY).toString());
}

void NotificationManager::applyCategoryDefinition(LipstickNotification *notification) const
{
    QVariantHash hints = notification->hints();

    // Apply a category definition, if any
    const QHash<QString, QString> categoryParameters(categoryDefinitionParameters(hints));
    QHash<QString, QString>::const_iterator it = categoryParameters.constBegin(), end = categoryParameters.constEnd();
    for ( ; it != end; ++it) {
        const QString &key(it.key());
        const QString &value(it.value());

        // TODO: this is wrong - in some cases we need to overwrite any existing value...
        // What would get broken by doing this?
        if (key == QString("appName")) {
            if (notification->appName().isEmpty()) {
                notification->setAppName(value);
            }
        } else if (key == QString("appIcon")) {
            if (notification->appIcon().isEmpty()) {
                notification->setAppIcon(value);
            }
        } else if (key == QString("summary")) {
            if (notification->summary().isEmpty()) {
                notification->setSummary(value);
            }
        } else if (key == QString("body")) {
            if (notification->body().isEmpty()) {
                notification->setBody(value);
            }
        } else if (key == QString("expireTimeout")) {
            if (notification->expireTimeout() == -1) {
                notification->setExpireTimeout(value.toInt());
            }
        } else if (!hints.contains(key)) {
            hints.insert(key, value);
        }
    }

    notification->setHints(hints);
}

void NotificationManager::publish(const LipstickNotification *notification, uint replacesId)
{
    const uint id(notification->replacesId());
    if (id == 0) {
        qWarning() << "Cannot publish notification without ID!";
        return;
    } else if (replacesId != 0 && replacesId != id) {
        qWarning() << "Cannot publish notification replacing independent ID!";
        return;
    }

    if (replacesId != 0) {
        // Delete the existing notification from the database
        DeleteNotification(id);
    }

    // Add the notification, its actions and its hints to the database
    execSQL("INSERT INTO notifications VALUES (?, ?, ?, ?, ?, ?)", QVariantList() << id << notification->appName() << notification->appIcon() << notification->summary() << notification->body() << notification->expireTimeout());
    foreach (const QString &action, notification->actions()) {
        execSQL("INSERT INTO actions VALUES (?, ?)", QVariantList() << id << action);
    }
    const QVariantHash hints(notification->hints());
    QVariantHash::const_iterator hit = hints.constBegin(), hend = hints.constEnd();
    for ( ; hit != hend; ++hit) {
        execSQL("INSERT INTO hints VALUES (?, ?, ?)", QVariantList() << id << hit.key() << hit.value());
    }

    NOTIFICATIONS_DEBUG("PUBLISH:" << notification->appName() << notification->appIcon() << notification->summary() << notification->body() << notification->actions() << notification->hints() << notification->expireTimeout() << "->" << id);
    modifiedIds.insert(id);
    if (!modificationTimer.isActive()) {
        modificationTimer.start();
    }
    if (replacesId == 0) {
        emit notificationAdded(id);
    }
}

void NotificationManager::restoreNotifications(bool update)
{
    if (connectToDatabase()) {
        if (checkTableValidity()) {
            fetchData(update);
        } else {
            database->close();
        }
    }
}

bool NotificationManager::connectToDatabase()
{
    QString databasePath = "/home/ceres" + QString(PRIVILEGED_DATA_PATH) + QDir::separator() + "Notifications";
    if (!QDir::root().exists(databasePath)) {
        QDir::root().mkpath(databasePath);
    }
    QString databaseName = databasePath + "/notifications.db";

    *database = QSqlDatabase::addDatabase("QSQLITE", metaObject()->className());
    database->setDatabaseName(databaseName);
    bool success = checkForDiskSpace(databasePath, MINIMUM_FREE_SPACE_NEEDED_IN_KB);
    if (success) {
        success = database->open();
        if (!success) {
            NOTIFICATIONS_DEBUG(database->lastError().driverText() << databaseName << database->lastError().databaseText());

            // If opening the database fails, try to recreate the database
            removeDatabaseFile(databaseName);
            success = database->open();
            NOTIFICATIONS_DEBUG("Unable to open database file. Recreating. Success: " << success);
        }
    } else {
        NOTIFICATIONS_DEBUG("Not enough free disk space available. Unable to open database.");
    }

    if (success) {
        // Set up the database mode to write-ahead locking to improve performance
        QSqlQuery(*database).exec("PRAGMA journal_mode=WAL");
    }

    return success;
}

bool NotificationManager::checkForDiskSpace(const QString &path, unsigned long freeSpaceNeeded)
{
    struct statfs st;
    bool spaceAvailable = false;
    if (statfs(path.toUtf8().data(), &st) != -1) {
        unsigned long freeSpaceInKb = (st.f_bsize * st.f_bavail) / 1024;
        if (freeSpaceInKb > freeSpaceNeeded) {
            spaceAvailable = true;
        }
    }
    return spaceAvailable;
}

void NotificationManager::removeDatabaseFile(const QString &path)
{
    // Remove also -shm and -wal files created when journal-mode=WAL is being used
    QDir::root().remove(path + "-shm");
    QDir::root().remove(path + "-wal");
    QDir::root().remove(path);
}

bool NotificationManager::checkTableValidity()
{
    bool result = true;
    bool recreateNotificationsTable = false;
    bool recreateActionsTable = false;
    bool recreateHintsTable = false;
    bool recreateExpirationTable = false;

    const int databaseVersion(schemaVersion());

    if (databaseVersion == 0) {
        // Unmodified database - remove any existing notifications, which might cause problems
        qWarning() << "Removing obsolete notifications";
        recreateNotificationsTable = true;
        recreateActionsTable = true;
        recreateHintsTable = true;
        recreateExpirationTable = true;

        if (!setSchemaVersion(1)) {
            qWarning() << "Unable to set database schema version!";
        }
    } else {
        // Check that the notifications table schema is as expected
        QSqlTableModel notificationsTableModel(0, *database);
        notificationsTableModel.setTable("notifications");
        recreateNotificationsTable = (notificationsTableModel.fieldIndex("id") == -1 ||
                                      notificationsTableModel.fieldIndex("app_name") == -1 ||
                                      notificationsTableModel.fieldIndex("app_icon") == -1 ||
                                      notificationsTableModel.fieldIndex("summary") == -1 ||
                                      notificationsTableModel.fieldIndex("body") == -1 ||
                                      notificationsTableModel.fieldIndex("expire_timeout") == -1);

        // Check that the actions table schema is as expected
        QSqlTableModel actionsTableModel(0, *database);
        actionsTableModel.setTable("actions");
        recreateActionsTable = (actionsTableModel.fieldIndex("id") == -1 ||
                                actionsTableModel.fieldIndex("action") == -1);

        // Check that the hints table schema is as expected
        QSqlTableModel hintsTableModel(0, *database);
        hintsTableModel.setTable("hints");
        recreateHintsTable = (hintsTableModel.fieldIndex("id") == -1 ||
                              hintsTableModel.fieldIndex("hint") == -1 ||
                              hintsTableModel.fieldIndex("value") == -1);

        // Check that the expiration table schema is as expected
        QSqlTableModel expirationTableModel(0, *database);
        expirationTableModel.setTable("expiration");
        recreateExpirationTable = (expirationTableModel.fieldIndex("id") == -1 ||
                                   expirationTableModel.fieldIndex("expire_at") == -1);
    }

    if (recreateNotificationsTable) {
        result &= recreateTable("notifications", "id INTEGER PRIMARY KEY, app_name TEXT, app_icon TEXT, summary TEXT, body TEXT, expire_timeout INTEGER");
    }

    if (recreateActionsTable) {
        result &= recreateTable("actions", "id INTEGER, action TEXT, PRIMARY KEY(id, action)");
    }

    if (recreateHintsTable) {
        result &= recreateTable("hints", "id INTEGER, hint TEXT, value TEXT, PRIMARY KEY(id, hint)");
    }

    if (recreateExpirationTable) {
        result &= recreateTable("expiration", "id INTEGER PRIMARY KEY, expire_at INTEGER");
    }

    return result;
}

int NotificationManager::schemaVersion()
{
    int result = -1;

    if (database->isOpen()) {
        QSqlQuery query(*database);
        if (query.exec("PRAGMA user_version") && query.next()) {
            result = query.value(0).toInt();
        }
    }

    return result;
}

bool NotificationManager::setSchemaVersion(int version)
{
    bool result = false;

    if (database->isOpen()) {
        QSqlQuery query(*database);
        if (query.exec(QString::fromLatin1("PRAGMA user_version=%1").arg(version))) {
            result = true;
        }
    }

    return result;
}

bool NotificationManager::recreateTable(const QString &tableName, const QString &definition)
{
    bool result = false;

    if (database->isOpen()) {
        QSqlQuery(*database).exec("DROP TABLE " + tableName);
        result = QSqlQuery(*database).exec("CREATE TABLE " + tableName + " (" + definition + ")");
    }

    return result;
}

void NotificationManager::fetchData(bool update)
{
    // Gather actions for each notification
    QSqlQuery actionsQuery("SELECT * FROM actions", *database);
    QSqlRecord actionsRecord = actionsQuery.record();
    int actionsTableIdFieldIndex = actionsRecord.indexOf("id");
    int actionsTableActionFieldIndex = actionsRecord.indexOf("action");
    QHash<uint, QStringList> actions;
    while (actionsQuery.next()) {
        const uint id = actionsQuery.value(actionsTableIdFieldIndex).toUInt();
        actions[id].append(actionsQuery.value(actionsTableActionFieldIndex).toString());
    }

    // Gather hints for each notification
    QSqlQuery hintsQuery("SELECT * FROM hints", *database);
    QSqlRecord hintsRecord = hintsQuery.record();
    int hintsTableIdFieldIndex = hintsRecord.indexOf("id");
    int hintsTableHintFieldIndex = hintsRecord.indexOf("hint");
    int hintsTableValueFieldIndex = hintsRecord.indexOf("value");
    QHash<uint, QVariantHash> hints;
    while (hintsQuery.next()) {
        const uint id = hintsQuery.value(hintsTableIdFieldIndex).toUInt();
        const QString hintName(hintsQuery.value(hintsTableHintFieldIndex).toString());
        const QVariant hintValue(hintsQuery.value(hintsTableValueFieldIndex));

        QVariant value;
        if (hintName == HINT_TIMESTAMP) {
            // Timestamps in the DB are already UTC but not marked as such, so they will
            // be converted again unless specified to be UTC
            QDateTime timestamp(QDateTime::fromString(hintValue.toString(), Qt::ISODate));
            timestamp.setTimeSpec(Qt::UTC);
            value = timestamp.toString(Qt::ISODate);
        } else {
            value = hintValue;
        }
        hints[id].insert(hintName, value);
    }

    // Gather expiration times for displayed notifications
    QSqlQuery expirationQuery("SELECT * FROM expiration", *database);
    QSqlRecord expirationRecord = expirationQuery.record();
    int expirationTableIdFieldIndex = expirationRecord.indexOf("id");
    int expirationTableExpireAtFieldIndex = expirationRecord.indexOf("expire_at");
    QHash<uint, qint64> expireAt;
    while (expirationQuery.next()) {
        const uint id = expirationQuery.value(expirationTableIdFieldIndex).toUInt();
        expireAt.insert(id, expirationQuery.value(expirationTableExpireAtFieldIndex).value<qint64>());
    }

    const qint64 currentTime(QDateTime::currentDateTimeUtc().toMSecsSinceEpoch());
    QList<LipstickNotification *> activeNotifications;
    QList<uint> transientIds;
    QList<uint> expiredIds;
    qint64 nextTimeout = std::numeric_limits<qint64>::max();
    bool unexpiredRemaining = false;

    // Create the notifications
    QSqlQuery notificationsQuery("SELECT * FROM notifications", *database);
    QSqlRecord notificationsRecord = notificationsQuery.record();
    int notificationsTableIdFieldIndex = notificationsRecord.indexOf("id");
    int notificationsTableAppNameFieldIndex = notificationsRecord.indexOf("app_name");
    int notificationsTableAppIconFieldIndex = notificationsRecord.indexOf("app_icon");
    int notificationsTableSummaryFieldIndex = notificationsRecord.indexOf("summary");
    int notificationsTableBodyFieldIndex = notificationsRecord.indexOf("body");
    int notificationsTableExpireTimeoutFieldIndex = notificationsRecord.indexOf("expire_timeout");
    while (notificationsQuery.next()) {
        const uint id = notificationsQuery.value(notificationsTableIdFieldIndex).toUInt();
        QString appName = notificationsQuery.value(notificationsTableAppNameFieldIndex).toString();
        QString appIcon = notificationsQuery.value(notificationsTableAppIconFieldIndex).toString();
        QString summary = notificationsQuery.value(notificationsTableSummaryFieldIndex).toString();
        QString body = notificationsQuery.value(notificationsTableBodyFieldIndex).toString();
        int expireTimeout = notificationsQuery.value(notificationsTableExpireTimeoutFieldIndex).toInt();

        const QStringList &notificationActions = actions[id];

        QVariantHash &notificationHints = hints[id];
        if (notificationHints.value(HINT_TRANSIENT).toBool()) {
            // This notification was transient, it should not be restored
            NOTIFICATIONS_DEBUG("TRANSIENT AT RESTORE:" << appName << appIcon << summary << body << notificationActions << notificationHints << expireTimeout << "->" << id);
            transientIds.append(id);
            continue;
        } else {
            // Mark this notification as restored
            notificationHints.insert(HINT_RESTORED, true);
        }

        bool expired = false;
        if (update && expireAt.contains(id)) {
            const qint64 expiry(expireAt.value(id));
            if (expiry <= currentTime) {
                expired = true;
            } else {
                nextTimeout = qMin(expiry, nextTimeout);
                unexpiredRemaining = true;
            }
        }

        LipstickNotification *notification = new LipstickNotification(appName, id, appIcon, summary, body, notificationActions, notificationHints, expireTimeout, this);
        notifications.insert(id, notification);

        if (id > previousNotificationID) {
            // Use the highest notification ID found as the previous notification ID
            previousNotificationID = id;
        }

        if (!expired) {
            activeNotifications.append(notification);
        } else {
            NOTIFICATIONS_DEBUG("EXPIRED AT RESTORE:" << appName << appIcon << summary << body << notificationActions << notificationHints << expireTimeout << "->" << id);
            expiredIds.append(id);
        }
    }

    if (update) {
        // Remove notifications no longer required
        foreach (uint id, transientIds) {
            DeleteNotification(id);
        }
    }

    int cullCount(activeNotifications.count() - MaxNotificationRestoreCount);
    if (update && cullCount > 0) {
        // Cull the least relevant notifications from this set
        std::sort(activeNotifications.begin(), activeNotifications.end(), notificationReverseOrder);

        foreach (LipstickNotification *n, activeNotifications) {
            const QVariant userRemovable = n->hints().value(HINT_USER_REMOVABLE);
            if (!userRemovable.isValid() || userRemovable.toBool()) {
                const uint id = n->replacesId();
                NOTIFICATIONS_DEBUG("CULLED AT RESTORE:" << n->appName() << n->appIcon() << n->summary() << n->body() << actions[id] << hints[id] << n->expireTimeout() << "->" << id);
                expiredIds.append(id);

                if (--cullCount == 0) {
                    break;
                }
            }
        }
    }

    if (update) {
        CloseNotifications(expiredIds, NotificationExpired);

        nextExpirationTime = unexpiredRemaining ? nextTimeout : 0;
        if (nextExpirationTime) {
            const qint64 nextTriggerInterval(nextExpirationTime - currentTime);
            expirationTimer.start(static_cast<int>(std::min<qint64>(nextTriggerInterval, std::numeric_limits<int>::max())));
        }
    }

    QList<uint> restoredIds;
    foreach (LipstickNotification *n, notifications) {
        const uint id = n->replacesId();
        connect(n, SIGNAL(actionInvoked(QString)), this, SLOT(invokeAction(QString)), Qt::QueuedConnection);
        connect(n, SIGNAL(removeRequested()), this, SLOT(removeNotificationIfUserRemovable()), Qt::QueuedConnection);

        NOTIFICATIONS_DEBUG("RESTORED:" << n->appName() << n->appIcon() << n->summary() << n->body() << actions[id] << hints[id] << n->expireTimeout() << "->" << id);
        restoredIds.append(id);
    }
    if (!restoredIds.isEmpty())
        emit notificationsModified(restoredIds);

    if (update) {
        qWarning() << "Notifications restored:" << notifications.count();
    }
}

void NotificationManager::commit()
{
    // Any aditional rules about when database commits are allowed can be added here
    if (!committed) {
        database->commit();
        committed = true;
    }

    qDeleteAll(removedNotifications);
    removedNotifications.clear();
}

void NotificationManager::execSQL(const QString &command, const QVariantList &args)
{
    if (!database->isOpen()) {
        return;
    }

    if (committed) {
        committed = false;
        database->transaction();
    }

    QSqlQuery query(*database);
    query.prepare(command);

    foreach(const QVariant &arg, args) {
        query.addBindValue(arg);
    }

    query.exec();

    if (query.lastError().isValid()) {
        NOTIFICATIONS_DEBUG(command << args << query.lastError());
    }

    databaseCommitTimer.start();
}

void NotificationManager::invokeAction(const QString &action)
{
    LipstickNotification *notification = qobject_cast<LipstickNotification *>(sender());
    if (notification != 0) {
        uint id = notifications.key(notification, 0);
        if (id > 0) {
            QString remoteAction = notification->hints().value(QString(HINT_REMOTE_ACTION_PREFIX) + action).toString();
            if (!remoteAction.isEmpty()) {
                NOTIFICATIONS_DEBUG("INVOKE REMOTE ACTION:" << action << id);

                // If a remote action has been defined for the given action, trigger it
                MRemoteAction(remoteAction).trigger();
            }

            for (int actionIndex = 0; actionIndex < notification->actions().count() / 2; actionIndex++) {
                // Actions are sent over as a list of pairs. Each even element in the list (starting at index 0) represents the identifier for the action. Each odd element in the list is the localized string that will be displayed to the user.
                if (notification->actions().at(actionIndex * 2) == action) {
                    NOTIFICATIONS_DEBUG("INVOKE ACTION:" << action << id);

                    emit ActionInvoked(id, action);
                }
            }

            // Unless marked as resident, we should remove the notification now
            const QVariant resident(notification->hints().value(HINT_RESIDENT));
            if (!resident.isValid() || resident.toBool() == false) {
                removeNotificationIfUserRemovable(id);
            }
        }
    }
}

void NotificationManager::removeNotificationIfUserRemovable(uint id)
{
    if (id == 0) {
        LipstickNotification *notification = qobject_cast<LipstickNotification *>(sender());
        if (notification != 0) {
            id = notifications.key(notification, 0);
        }
    }

    LipstickNotification *notification = notifications.value(id);
    if (!notification) {
        return;
    }

    QVariant userRemovable = notification->hints().value(HINT_USER_REMOVABLE);
    if (!userRemovable.isValid() || userRemovable.toBool()) {
        // The notification should be removed if user removability is not defined (defaults to true) or is set to true
        QVariant userCloseable = notification->hints().value(HINT_USER_CLOSEABLE);
        if (!userCloseable.isValid() || userCloseable.toBool()) {
            // The notification should be closed if user closeability is not defined (defaults to true) or is set to true
            CloseNotification(id, NotificationDismissedByUser);
        } else {
            // Uncloseable notifications should be only removed
            emit notificationRemoved(id);

            // Mark the notification as hidden
            execSQL("INSERT INTO hints VALUES (?, ?, ?)", QVariantList() << id << HINT_HIDDEN << true);
        }
    }
}

void NotificationManager::expire()
{
    const qint64 currentTime(QDateTime::currentDateTimeUtc().toMSecsSinceEpoch());
    QList<uint> expiredIds;
    qint64 nextTimeout = std::numeric_limits<qint64>::max();
    bool unexpiredRemaining = false;

    QSqlQuery expirationQuery("SELECT * FROM expiration", *database);
    QSqlRecord expirationRecord = expirationQuery.record();
    int expirationTableIdFieldIndex = expirationRecord.indexOf("id");
    int expirationTableExpireAtFieldIndex = expirationRecord.indexOf("expire_at");
    while (expirationQuery.next()) {
        const uint id = expirationQuery.value(expirationTableIdFieldIndex).toUInt();
        const qint64 expiry = expirationQuery.value(expirationTableExpireAtFieldIndex).value<qint64>();

        if (expiry <= currentTime) {
            expiredIds.append(id);
        } else {
            nextTimeout = qMin(expiry, nextTimeout);
            unexpiredRemaining = true;
        }
    }

    CloseNotifications(expiredIds, NotificationExpired);

    nextExpirationTime = unexpiredRemaining ? nextTimeout : 0;
    if (nextExpirationTime) {
        const qint64 nextTriggerInterval(nextExpirationTime - currentTime);
        expirationTimer.start(static_cast<int>(std::min<qint64>(nextTriggerInterval, std::numeric_limits<int>::max())));
    }
}

void NotificationManager::reportModifications()
{
    if (modifiedIds.count() == 1) {
        emit notificationModified(*modifiedIds.begin());
    } else if (!modifiedIds.isEmpty()) {
        emit notificationsModified(modifiedIds.values());
    }
    modifiedIds.clear();
}

void NotificationManager::removeUserRemovableNotifications()
{
    QList<uint> closableNotifications;

    // Find any closable notifications we can close as a batch
    QHash<uint, LipstickNotification *>::const_iterator it = notifications.constBegin(), end = notifications.constEnd();
    for ( ; it != end; ++it) {
        LipstickNotification *notification(it.value());
        QVariant userRemovable = notification->hints().value(HINT_USER_REMOVABLE);
        if (!userRemovable.isValid() || userRemovable.toBool()) {
            QVariant userCloseable = notification->hints().value(HINT_USER_CLOSEABLE);
            if (!userCloseable.isValid() || userCloseable.toBool()) {
                closableNotifications.append(it.key());
            }
        }
    }

    CloseNotifications(closableNotifications, NotificationDismissedByUser);

    // Remove any remaining notifications
    foreach(uint id, notifications.keys()) {
        removeNotificationIfUserRemovable(id);
    }
}
