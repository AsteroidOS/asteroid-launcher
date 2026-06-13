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
#ifndef SHUTDOWNSCREEN_H
#define SHUTDOWNSCREEN_H

#include <QObject>

class ShutdownScreen : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool windowVisible READ windowVisible WRITE setWindowVisible NOTIFY windowVisibleChanged)

public:
    explicit ShutdownScreen(QObject *parent = 0);

    //! Returns whether the shutdown screen overlay should be shown.
    bool windowVisible() const;

    //! Sets whether the shutdown screen overlay should be shown.
    void setWindowVisible(bool visible);

signals:
    //! Sent when the visibility of the overlay has changed.
    void windowVisibleChanged();

private slots:
    //! DSME is shutting the system down: show the shutdown screen
    void handleShutdown();

    //! DSME denied a shutdown/reboot request, e.g. because USB is connected
    void handleShutdownDenied(const QString &reqType, const QString &reason);

    //! DSME is shutting down because the battery is empty
    void handleBatteryEmpty();

    //! DSME announced a state change (e.g. "REBOOT")
    void handleStateChange(const QString &state);

    //! DSME's thermal manager reported a new thermal state
    void handleThermalStateChange(const QString &state);

private:
    /*!
     * Shows a system notification.
     *
     * \param category the category of the notification
     * \param body the body text of the notification
     */
    void createAndPublishNotification(const QString &category, const QString &body);

    //! Whether the shutdown screen overlay should be shown
    bool m_visible = false;

    //! The shutdown mode to be communicated to the UI
    QString shutdownMode;

#ifdef UNIT_TEST
    friend class Ut_ShutdownScreen;
#endif
};

#endif // SHUTDOWNSCREEN_H
