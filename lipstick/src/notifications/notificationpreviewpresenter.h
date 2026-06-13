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

#ifndef NOTIFICATIONPREVIEWPRESENTER_H
#define NOTIFICATIONPREVIEWPRESENTER_H

#include "lipsticknotification.h"
#include <QObject>

class NotificationFeedbackPlayer;

class QMceTkLock;
class QMceDisplay;

/*!
 * \class NotificationPreviewPresenter
 *
 * \brief Presents notification previews one at a time.
 *
 * Tracks which notification (if any) should currently be previewed; the
 * preview overlay in the compositor scene renders it.
 */
class NotificationPreviewPresenter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(LipstickNotification *notification READ notification NOTIFY notificationChanged)

public:
    /*!
     * Creates a notification preview presenter.
     *
     * \param parent the parent object
     */
    explicit NotificationPreviewPresenter(QObject *parent = 0);

    /*!
     * Destroys the notification preview presenter.
     */
    virtual ~NotificationPreviewPresenter();

    /*!
     * Returns the notification to be currently shown or 0 if no notification
     * should be shown.
     *
     * \return the notification to be currently shown or 0 if no notification should be shown
     */
    LipstickNotification *notification() const;

signals:
    //! Sent when the notification to be shown has changed.
    void notificationChanged();

    //! Sent when a notification is considered presented by the presenter
    void notificationPresented(uint id);

public slots:
    /*!
     * Advances to the next notification to be previewed, if any, or clears
     * the current notification when the queue is empty.
     */
    void showNextNotification();

private slots:
    /*!
     * Updates the notification with the given ID.
     *
     * \param id the ID of the notification to be updated
     */
    void updateNotification(uint id);

    /*!
     * Removes the notification with the given ID.
     *
     * \param id the ID of the notification to be removed
     */
    void removeNotification(uint id, bool onlyFromQueue = false);

private:
    //! Checks whether the given notification has a preview body and a preview summary.
    bool notificationShouldBeShown(LipstickNotification *notification);

    //! Sets the given notification as the current notification
    void setCurrentNotification(LipstickNotification *notification);

    //! Notifications to be shown
    QList<LipstickNotification *> notificationQueue;

    //! Notification currently being shown
    LipstickNotification *currentNotification;

    //! Player for notification feedbacks
    NotificationFeedbackPlayer *notificationFeedbackPlayer;

    //! For getting information about the touch screen lock state
    QMceTkLock *locks;

    //! For getting information about the display state
    QMceDisplay *displayState;

#ifdef UNIT_TEST
    friend class Ut_NotificationPreviewPresenter;
#endif
};

#endif // NOTIFICATIONPREVIEWPRESENTER_H
