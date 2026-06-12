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

#ifndef NOTIFICATIONMANAGER_H
#define NOTIFICATIONMANAGER_H

#include "lipstickglobal.h"
#include "lipsticknotification.h"
#include <QObject>
#include <QTimer>
#include <QSet>
#include <QDBusContext>

class AndroidPriorityStore;
class CategoryDefinitionStore;
class QSqlDatabase;

/*!
 * \class NotificationManager
 *
 * \brief The notification manager allows applications to display notifications to the user.
 *
 * The notification manager implements a desktop notifications service based
 * on the <a href="http://www.galago-project.org/specs/notification/0.9/">Desktop Notifications Specification</a>.
 * The service is registered as org.freedesktop.Notifications on the D-Bus
 * session bus in the path /org/freedesktop/Notifications.
 */
class LIPSTICK_EXPORT NotificationManager : public QObject, public QDBusContext
{
    Q_OBJECT

public:
    //! Standard hint: The urgency level.
    static const char *HINT_URGENCY;

    //! Standard hint: The type of notification this is.
    static const char *HINT_CATEGORY;

    //! Standard hint: If true, the notification should be removed after display.
    static const char *HINT_TRANSIENT;

    //! Standard hint: If true, the notification should not be removed after activation.
    static const char *HINT_RESIDENT;

    //! Standard hint: Icon of the notification: either a file:// URL, an absolute path, or a token to be satisfied by the 'theme' image provider.
    static const char *HINT_IMAGE_PATH;

    //! Nemo hint: Icon of the notification. Allows the icon to be set using a category definition file without specifying it in the Notify() call.
    static const char *HINT_ICON;

    //! Nemo hint: Item count represented by the notification.
    static const char *HINT_ITEM_COUNT;

    //! Nemo hint: Priority level of the notification.
    static const char *HINT_PRIORITY;

    //! Nemo hint: Timestamp of the notification.
    static const char *HINT_TIMESTAMP;

    //! Nemo hint: Icon of the preview of the notification.
    static const char *HINT_PREVIEW_ICON;

    //! Nemo hint: Body text of the preview of the notification.
    static const char *HINT_PREVIEW_BODY;

    //! Nemo hint: Summary text of the preview of the notification.
    static const char *HINT_PREVIEW_SUMMARY;

    //! Nemo hint: Remote action of the notification. Prefix only: the action identifier is to be appended.
    static const char *HINT_REMOTE_ACTION_PREFIX;

    //! Nemo hint: Icon for the remote action of the notification. Prefix only: the action identifier is to be appended.
    static const char *HINT_REMOTE_ACTION_ICON_PREFIX;

    //! Nemo hint: User removability of the notification.
    static const char *HINT_USER_REMOVABLE;

    //! Nemo hint: User closeability of the notification.
    static const char *HINT_USER_CLOSEABLE;

    //! Nemo hint: Feedback of the notification.
    static const char *HINT_FEEDBACK;

    //! Nemo hint: Suppress any feedback that would otherwise be emitted.
    static const char *HINT_FEEDBACK_SUPPRESSED;

    //! Nemo hint: Whether the notification is hidden.
    static const char *HINT_HIDDEN;

    //! Nemo hint: Whether to turn the screen on when displaying preview
    static const char *HINT_DISPLAY_ON;

    //! Nemo hint: Whether to disable LED feedbacks when there is no body and summary
    static const char *HINT_LED_DISABLED_WITHOUT_BODY_AND_SUMMARY;

    //! Nemo hint: Indicates the origin of the notification
    static const char *HINT_ORIGIN;

    //! Nemo hint: Indicates the Android package name from which this notification originates
    static const char *HINT_ORIGIN_PACKAGE;

    //! Nemo hint: Indicates the identifer of the owner for notification
    static const char *HINT_OWNER;

    //! Nemo hint: Specifies the maximum number of content lines to display (including summary)
    static const char *HINT_MAX_CONTENT_LINES;

    //! Nemo hint: Indicates that this notification has been restored from persistent storage since the last update
    static const char *HINT_RESTORED;

    //! Notification closing reasons used in the NotificationClosed signal
    enum NotificationClosedReason {
        //! The notification expired.
        NotificationExpired = 1,
        //! The notification was dismissed by the user.
        NotificationDismissedByUser,
        //! The notification was closed by a call to CloseNotification.
        CloseNotificationCalled
    };

    /*!
     * Returns a singleton instance of the notification manager.
     *
     * \param owner true if the calling application is taking ownership of the notifications data
     * \return an instance of the notification manager
     */
    static NotificationManager *instance(bool owner = true);

    /*!
     * Returns a notification with the given ID.
     *
     * \param id the ID of the notification to return
     * \return the notification with the given ID
     */
    LipstickNotification *notification(uint id) const;

    /*!
     * Returns a list of notification IDs.
     *
     * \return a list of notification IDs.
     */
    QList<uint> notificationIds() const;

    /*!
     * Returns an array of strings. Each string describes an optional capability
     * implemented by the server. Refer to the Desktop Notification Specifications for
     * the defined capabilities.
     *
     * \return an array of strings, each string describing an optional capability implemented by the server
     */
    QStringList GetCapabilities();

    /*!
     * Sends a notification to the notification server.
     *
     * \param appName The optional name of the application sending the notification. Can be blank.
     * \param replacesId The optional notification ID that this notification replaces. The server must atomically (ie with no flicker or other visual cues) replace the given notification with this one. This allows clients to effectively modify the notification while it's active. A value of value of 0 means that this notification won't replace any existing notifications.
     * \param appIcon The optional program icon of the calling application. Can be an empty string, indicating no icon.
     * \param summary The summary text briefly describing the notification.
     * \param body The optional detailed body text. Can be empty.
     * \param actions Actions are sent over as a list of pairs. Each even element in the list (starting at index 0) represents the identifier for the action. Each odd element in the list is the localized string that will be displayed to the user.
     * \param hints Optional hints that can be passed to the server from the client program. Although clients and servers should never assume each other supports any specific hints, they can be used to pass along information, such as the process PID or window ID, that the server may be able to make use of. Can be empty.
     * \param expireTimeout he timeout time in milliseconds since the display of the notification at which the notification should automatically close.  If -1, the notification's expiration time is dependent on the notification server's settings, and may vary for the type of notification. If 0, never expire.
     */
    uint Notify(const QString &appName, uint replacesId, const QString &appIcon, const QString &summary, const QString &body, const QStringList &actions, const QVariantHash &hints, int expireTimeout);

    /*!
     * Causes a notification to be forcefully closed and removed from the user's view.
     * It can be used, for example, in the event that what the notification pertains
     * to is no longer relevant, or to cancel a notification with no expiration time.
     * The NotificationClosed signal is emitted by this method.
     *
     * \param id the ID of the notification to be closed
     * \param closeReason the reason for the closure of this notification
     */
    void CloseNotification(uint id, NotificationClosedReason closeReason = CloseNotificationCalled);

    /*!
     * Causes all listed notifications to be forcefully closed and removed from the user's view.
     * The NotificationClosed signal is emitted by this method for each closed notification.
     *
     * \param ids the IDs of the notifications to be closed
     * \param closeReason the reason for the closure of these notifications
     */
    void CloseNotifications(const QList<uint> &ids, NotificationClosedReason closeReason = CloseNotificationCalled);

    /*!
     * Mark the notification as displayed.  If the notification has an expiry timeout
     * value defined, it will apply from when the notification is marked as displayed.
     *
     * \param id the ID of the notification to be closed
     */
    void MarkNotificationDisplayed(uint id);

    /*!
     * This message returns the information on the server. Specifically, the server name, vendor,
     * and version number.
     *
     * \param name The product name of the server.
     * \param vendor The vendor name. For example, "KDE," "GNOME," "freedesktop.org," or "Microsoft."
     * \param version The server's version number.
     * \return an empty string
     */
    QString GetServerInformation(QString &name, QString &vendor, QString &version);

    /*!
     * Returns the notifications sent by a specified application.
     *
     * \param owner the identifier of the application to get notifications for
     * \return a list of notifications for the application
     */
    NotificationList GetNotifications(const QString &owner);

signals:
    /*!
     * A completed notification is one that has timed out, or has been dismissed by the user.
     *
     * \param id The ID of the notification that was closed.
     * \param reason The reason the notification was closed. 1 - The notification expired. 2 - The notification was dismissed by the user. 3 - The notification was closed by a call to CloseNotification. 4 - Undefined/reserved reasons.
     */
    void NotificationClosed(uint id, uint reason);

    /*!
     * This signal is emitted when one of the following occurs:
     *   * The user performs some global "invoking" action upon a notification. For instance, clicking somewhere on the notification itself.
     *   * The user invokes a specific action as specified in the original Notify request. For example, clicking on an action button.
     *
     * \param id The ID of the notification emitting the ActionInvoked signal.
     * \param actionKey The key of the action invoked. These match the keys sent over in the list of actions.
     */
    void ActionInvoked(uint id, const QString &actionKey);

    /*!
     * Emitted when a notification is added.
     *
     * \param id the ID of the added notification
     */
    void notificationAdded(uint id);

    /*!
     * Emitted when a notification is modified (added or updated).
     *
     * \param id the ID of the modified notification
     */
    void notificationModified(uint id);

    /*!
     * Emitted when a group of notifications is collectively modified (added or updated).
     *
     * \param ids the IDs of the modified notifications
     */
    void notificationsModified(const QList<uint> &ids);

    /*!
     * Emitted when a notification is removed.
     *
     * \param id the ID of the removed notification
     */
    void notificationRemoved(uint id);

    /*!
     * Emitted when a group of notifications is collectively removed.
     *
     * \param ids the IDs of the removed notifications
     */
    void notificationsRemoved(const QList<uint> &ids);

public slots:
    /*!
     * Removes all notifications which are user removable.
     */
    void removeUserRemovableNotifications();

private slots:
    /*!
     * Removes all notifications with the specified category.
     *
     * \param category the category of the notifications to remove
     */
    void removeNotificationsWithCategory(const QString &category);

    /*!
     * Update category data of all notifications with the
     * specified category.
     *
     * \param category the category of the notifications to update
     */
    void updateNotificationsWithCategory(const QString &category);

    /*!
     * Commits the current database transaction, if any.
     * Also destroys any removed notifications.
     */
    void commit();

    /*!
     * Invokes the given action if it is has been defined. The
     * sender is expected to be a Notification.
     *
     * \param action the action to be invoked
     */
    void invokeAction(const QString &action);

    /*!
     * Removes a notification if it is removable by the user.
     *
     * \param id the ID of the notification to be removed
     */
    void removeNotificationIfUserRemovable(uint id = 0);

    /*!
     * Expires any notifications whose expiration time has been reached.
     */
    void expire();

    /*!
     * Reports any notifications that have been modified since the last report.
     */
    void reportModifications();

private:
    /*!
     * Creates a new notification manager.
     *
     * \param parent the parent object
     * \param owner true if the manager is taking ownership of the notifications data
     */
    NotificationManager(QObject *parent, bool owner);

    //! Destroys the notification manager.
    virtual ~NotificationManager();

    /*!
     * Returns the next available notification ID
     *
     * \return The next available notification ID
     */
    uint nextAvailableNotificationID();

    /*!
     * Returns all key-value pairs in the requested category definition.
     *
     * \param hints the notification hints from which to determine the category definition to report
     */
    QHash<QString, QString> categoryDefinitionParameters(const QVariantHash &hints) const;

    /*!
     * Update a notification by applying the changes implied by the catgeory definition.
     */
    void applyCategoryDefinition(LipstickNotification *notification) const;

    /*!
     * Makes a notification known to the system, or updates its properties if already published.
     */
    void publish(const LipstickNotification *notification, uint replacesId);

    //! Restores the notifications from a database on the disk
    void restoreNotifications(bool update);

    /*!
     * Creates a connection to the Sqlite database.
     *
     * \return \c true if the connection was successfully established, \c false otherwise
     */
    bool connectToDatabase();

    /*!
     * Deletes a notification from the system, without any reporting.
     */
    void DeleteNotification(uint id);

    /*!
     * Checks whether there is enough free disk space available.
     *
     * \param path any path to the file system from which the space should be checked
     * \param freeSpaceNeeded free space needed in kilobytes
     * \return \c true if there is enough free space in given file system, \c false otherwise
     */
    static bool checkForDiskSpace(const QString &path, unsigned long freeSpaceNeeded);

    /*!
     * Removes a database file from the filesystem. Removes related -wal and -shm files as well.
     *
     * \param path the path of the database file to be removed
     */
    static void removeDatabaseFile(const QString &path);

    /*!
     * Ensures that all database tables have the requires fields.
     * Recreates the tables if needed.
     *
     * \return \c true if the database can be used, \c false otherwise
     */
    bool checkTableValidity();

    /*!
     * Returns the schema version of the database.
     *
     * \return the version number the database schema is currently set to.
     */
    int schemaVersion();

    /*!
     * Sets the schema version of the database.
     *
     * \param version the version number to set the database schema to.
     * \return \c true if the database is updated.
     */
    bool setSchemaVersion(int version);

    /*!
     * Recreates a table in the database.
     *
     * \param tableName the name of the table to be created
     * \param definition SQL definition for the table
     * \return \c true if the table was created, \c false otherwise
     */
    bool recreateTable(const QString &tableName, const QString &definition);

    //! Fills the notifications hash table with data from the database
    void fetchData(bool update);

    /*!
     * Executes a SQL command in the database. Starts a new transaction if none is active currently, otherwise
     * the command goes to the active transaction. Restarts the transaction commit timer.
     * \param command the SQL command
     * \param args list of values to be bound to the positional placeholders ('?' -character) in the command.
     */
    void execSQL(const QString &command, const QVariantList &args = QVariantList());

    //! The singleton notification manager instance
    static NotificationManager *instance_;

    //! Hash of all notifications keyed by notification IDs
    QHash<uint, LipstickNotification*> notifications;

    //! Notifications waiting to be destroyed
    QSet<LipstickNotification *> removedNotifications;

    //! Previous notification ID used
    uint previousNotificationID;

    //! The category definition store
    CategoryDefinitionStore *categoryDefinitionStore;

    //! The Android application priority store
    AndroidPriorityStore *androidPriorityStore;

    //! Database for the notifications
    QSqlDatabase *database;

    //! Whether the current database transaction has been committed to the database
    bool committed;

    //! Timer for triggering the commit of the current database transaction
    QTimer databaseCommitTimer;

    //! Timer for triggering the expiration of displayed notifications
    QTimer expirationTimer;

    //! Next trigger time for the expirationTimer, relative to epoch
    qint64 nextExpirationTime;

    //! IDs of notifications modified since the last report
    QSet<uint> modifiedIds;

    //! Timer for triggering the reporting of modified notifications
    QTimer modificationTimer;

#ifdef UNIT_TEST
    friend class Ut_NotificationManager;
#endif
};

#endif // NOTIFICATIONMANAGER_H
