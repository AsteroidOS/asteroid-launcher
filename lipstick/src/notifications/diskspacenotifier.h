/***************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
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

#ifndef DISKSPACENOTIFIER_H_
#define DISKSPACENOTIFIER_H_

#include <QObject>
#include <QMap>
#include <QPair>

/*!
 * Disk space notifier sends disk space notifications when the disk is full.
 */
class DiskSpaceNotifier : public QObject
{
    Q_OBJECT

public:
    /*!
     * Creates a disk space notifier.
     */
    DiskSpaceNotifier(QObject *parent = NULL);

    /*!
     * Destroys the disk space notifier.
     */
    virtual ~DiskSpaceNotifier();

private slots:
    /*!
     * Handles the disk space change by sending a notification if necessary.
     *
     * \param path the path for which disk space has changed
     * \param percentage the new usage percentage
     */
    void handleDiskSpaceChange(const QString &path, int percentage);

    //! Initializes the disk space notifier by removing any previous notifications
    void removeDiskSpaceNotifications();

private:
    //! Notifications sent for each path. The first bool in the pair is whether the threshold notification was sent, second whether the 100% notification was sent.
    QMap<QString, QPair<bool, bool> > notificationsSentForPath;

    //! The disk space notification
    uint notificationId;

#ifdef UNIT_TEST
    friend class Ut_DiskSpaceNotifier;
#endif
};

#endif /* DISKSPACENOTIFIER_H_ */
