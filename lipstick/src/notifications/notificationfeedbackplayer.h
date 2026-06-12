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

#ifndef NOTIFICATIONFEEDBACKPLAYER_H
#define NOTIFICATIONFEEDBACKPLAYER_H

#include "lipstickglobal.h"
#include <QObject>
#include <QHash>

class LipstickNotification;
namespace Ngf {
    class Client;
}

/*!
 * \class NotificationFeedbackPlayer
 *
 * \brief Plays non-graphical feedback for notifications.
 */
class LIPSTICK_EXPORT NotificationFeedbackPlayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int minimumPriority READ minimumPriority WRITE setMinimumPriority NOTIFY minimumPriorityChanged)

public:
    explicit NotificationFeedbackPlayer(QObject *parent = 0);

    /*!
     * Returns the minimum priority of notifications for which a feedback should be played
     *
     * \return the minimum priority of notifications for which a feedback should be played
     */
    int minimumPriority() const;

    /*!
     * Sets the minimum priority of notifications for which a feedback should be played
     *
     * \param minimumPriority the minimum priority of notifications for which a feedback should be played
     */
    void setMinimumPriority(int minimumPriority);

signals:
    //! Emitted when the minimum priority of notifications for which a feedback should be played has changed
    void minimumPriorityChanged();

private slots:
    //! Initializes the feedback player
    void init();

    /*!
     * Adds the notification with the given ID.
     *
     * \param id the ID of the notification to be added
     */
    void addNotification(uint id);

    /*!
     * Removes the notification with the given ID.
     *
     * \param id the ID of the notification to be removed
     */
    void removeNotification(uint id);

private:
    //! Check whether feedbacks should be enabled for the given notification
    bool isEnabled(LipstickNotification *notification);

    //! Non-graphical feedback player
    Ngf::Client *ngfClient;

    //! A mapping between notification IDs and NGF play IDs.
    QMultiHash<LipstickNotification *, uint> idToEventId;

    //! The minimum priority of notifications for which a feedback should be played
    int minimumPriority_;

#ifdef UNIT_TEST
    friend class Ut_NotificationFeedbackPlayer;
#endif
};

#endif // NOTIFICATIONFEEDBACKPLAYER_H
