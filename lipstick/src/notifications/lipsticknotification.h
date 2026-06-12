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

#ifndef LIPSTICKNOTIFICATION_H
#define LIPSTICKNOTIFICATION_H

#include "lipstickglobal.h"
#include <QStringList>
#include <QDateTime>
#include <QVariantHash>

class QDBusArgument;

/*!
 * An object for storing information about a single notification.
 */
class LIPSTICK_EXPORT LipstickNotification : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString appName READ appName CONSTANT)
    Q_PROPERTY(uint replacesId READ replacesId CONSTANT)
    Q_PROPERTY(QString appIcon READ appIcon CONSTANT)
    Q_PROPERTY(QString summary READ summary NOTIFY summaryChanged)
    Q_PROPERTY(QString body READ body NOTIFY bodyChanged)
    Q_PROPERTY(QStringList actions READ actions CONSTANT)
    Q_PROPERTY(QVariantMap hints READ hintValues NOTIFY hintsChanged)
    Q_PROPERTY(int expireTimeout READ expireTimeout CONSTANT)
    Q_PROPERTY(QString icon READ icon NOTIFY iconChanged)
    Q_PROPERTY(QDateTime timestamp READ timestamp NOTIFY timestampChanged)
    Q_PROPERTY(QString previewIcon READ previewIcon NOTIFY previewIconChanged)
    Q_PROPERTY(QString previewSummary READ previewSummary NOTIFY previewSummaryChanged)
    Q_PROPERTY(QString previewBody READ previewBody NOTIFY previewBodyChanged)
    Q_PROPERTY(int urgency READ urgency NOTIFY urgencyChanged)
    Q_PROPERTY(int itemCount READ itemCount NOTIFY itemCountChanged)
    Q_PROPERTY(int priority READ priority NOTIFY priorityChanged)
    Q_PROPERTY(QString category READ category NOTIFY categoryChanged)
    Q_PROPERTY(bool userRemovable READ isUserRemovable NOTIFY userRemovableChanged)
    Q_PROPERTY(QVariantList remoteActions READ remoteActions CONSTANT)
    Q_PROPERTY(QString origin READ origin CONSTANT)
    Q_PROPERTY(QString owner READ owner CONSTANT)
    Q_PROPERTY(int maxContentLines READ maxContentLines CONSTANT)

public:
    /*!
     * Creates an object for storing information about a single notification.
     *
     * \param appName name of the application sending the notification
     * \param replacesID the ID of the notification
     * \param appIcon icon ID of the application sending the notification
     * \param summary summary text for the notification
     * \param body body text for the notification
     * \param actions actions for the notification as a list of identifier/string pairs
     * \param hints hints for the notification
     * \param expireTimeout expiration timeout for the notification
     * \param parent the parent QObject
     */
    LipstickNotification(const QString &appName, uint replacesId, const QString &appIcon, const QString &summary, const QString &body, const QStringList &actions, const QVariantHash &hints, int expireTimeout, QObject *parent = 0);

    /*!
     * Creates a new uninitialized representation of a notification.
     *
     * \param parent the parent QObject
     */
    LipstickNotification(QObject *parent = 0);

    //! Returns the name of the application sending the notification
    QString appName() const;

    //! Sets the name of the application sending the notification
    void setAppName(const QString &appName);

    //! Returns the ID of the notification
    uint replacesId() const;

    //! Returns the icon ID of the application sending the notification
    QString appIcon() const;

    //! Sets the icon ID of the application sending the notification
    void setAppIcon(const QString &appIcon);

    //! Returns the summary text for the notification
    QString summary() const;

    //! Sets the summary text for the notification
    void setSummary(const QString &summary);

    //! Returns the body text for the notification
    QString body() const;

    //! Sets the body text for the notification
    void setBody(const QString &body);

    //! Returns the actions for the notification as a list of identifier/string pairs
    QStringList actions() const;

    //! Sets the actions for the notification as a list of identifier/string pairs
    void setActions(const QStringList &actions);

    //! Returns the hints for the notification
    QVariantHash hints() const;
    QVariantMap hintValues() const;

    //! Sets the hints for the notification
    void setHints(const QVariantHash &hints);

    //! Returns the expiration timeout for the notification
    int expireTimeout() const;

    //! Sets the expiration timeout for the notification
    void setExpireTimeout(int expireTimeout);

    //! Returns the icon ID for the notification
    QString icon() const;

    //! Returns the timestamp for the notification
    QDateTime timestamp() const;

    //! Returns the icon ID for the preview of the notification
    QString previewIcon() const;

    //! Returns the summary text for the preview of the notification
    QString previewSummary() const;

    //! Returns the body text for the preview of the notification
    QString previewBody() const;

    //! Returns the urgency of the notification
    int urgency() const;

    //! Returns the item count of the notification
    int itemCount() const;

    //! Returns the priority of the notification
    int priority() const;

    //! Returns the category of the notification
    QString category() const;

    //! Returns the user removability of the notification
    bool isUserRemovable() const;

    //! Returns true if the notification has been hidden to prevent further display
    bool hidden() const;

    //! Returns the remote actions invokable by the notification
    QVariantList remoteActions() const;

    //! Returns an indicator for the origin of the notification
    QString origin() const;

    //! Returns an indicator for the notification owner
    QString owner() const;

    //! Returns the maximum number of content lines requested for display
    int maxContentLines() const;

    //! Returns true if the notification has been restored since it was last modified
    bool restored() const;

    //! \internal
    quint64 internalTimestamp() const;

    /*!
     * Creates a copy of an existing representation of a notification.
     * This constructor should only be used for populating the notification
     * list from D-Bus structures.
     *
     * \param notification the notification representation to a create copy of
     */
    explicit LipstickNotification(const LipstickNotification &notification);

    friend QDBusArgument &operator<<(QDBusArgument &, const LipstickNotification &);
    friend const QDBusArgument &operator>>(const QDBusArgument &, LipstickNotification &);
    //! \internal_end

signals:
    /*!
     * Sent when an action defined for the notification is invoked.
     *
     * \param action the action that was invoked
     */
    void actionInvoked(QString action);

    //! Sent when the removal of this notification was requested.
    void removeRequested();

    //! Sent when the summary has been modified
    void summaryChanged();

    //! Sent when the body has been modified
    void bodyChanged();

    //! Sent when the hints have been modified
    void hintsChanged();

    //! Sent when the icon has been modified
    void iconChanged();

    //! Sent when the timestamp has changed
    void timestampChanged();

    //! Sent when the preview icon has been modified
    void previewIconChanged();

    //! Sent when the preview summary has been modified
    void previewSummaryChanged();

    //! Sent when the preview body has been modified
    void previewBodyChanged();

    //! Sent when the urgency has been modified
    void urgencyChanged();

    //! Sent when the item count has been modified
    void itemCountChanged();

    //! Sent when the priority has been modified
    void priorityChanged();

    //! Sent when the category has been modified
    void categoryChanged();

    //! Sent when the user removability has been modified
    void userRemovableChanged();

private:
    void updateHintValues();

    //! Name of the application sending the notification
    QString appName_;

    //! The ID of the notification
    uint replacesId_;

    //! Icon ID of the application sending the notification
    QString appIcon_;

    //! Summary text for the notification
    QString summary_;

    //! Body text for the notification
    QString body_;

    //! Actions for the notification as a list of identifier/string pairs
    QStringList actions_;

    //! Hints for the notification
    QVariantHash hints_;
    QVariantMap hintValues_;

    //! Expiration timeout for the notification
    int expireTimeout_;

    // Cached values for speeding up comparisons:
    int priority_;
    quint64 timestamp_;
};

// Order notifications by descending priority then timestamp:
bool operator<(const LipstickNotification &lhs, const LipstickNotification &rhs);

Q_DECLARE_METATYPE(LipstickNotification)

class LIPSTICK_EXPORT NotificationList
{
public:
    NotificationList();
    NotificationList(const QList<LipstickNotification *> &notificationList);
    NotificationList(const NotificationList &notificationList);
    QList<LipstickNotification *> notifications() const;
    friend QDBusArgument &operator<<(QDBusArgument &, const NotificationList &);
    friend const QDBusArgument &operator>>(const QDBusArgument &, NotificationList &);

private:
    QList<LipstickNotification *> notificationList;
};

Q_DECLARE_METATYPE(NotificationList)

#endif // LIPSTICKNOTIFICATION_H
