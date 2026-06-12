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
#include "lipstickglobal.h"

class HomeWindow;

class LIPSTICK_EXPORT ShutdownScreen : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool windowVisible READ windowVisible WRITE setWindowVisible NOTIFY windowVisibleChanged)

public:
    explicit ShutdownScreen(QObject *parent = 0);

    /*!
     * Returns whether the window is visible or not.
     *
     * \return \c true if the window is visible, \c false otherwise
     */
    bool windowVisible() const;

    /*!
     * Sets the visibility of the window.
     *
     * \param visible \c true if the window should be visible, \c false otherwise
     */
    void setWindowVisible(bool visible);

signals:
    //! Sent when the visibility of the window has changed.
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

    //! The shutdown screen window
    HomeWindow *window;

    //! The shutdown mode to be communicated to the UI
    QString shutdownMode;

#ifdef UNIT_TEST
    friend class Ut_ShutdownScreen;
#endif
};

#endif // SHUTDOWNSCREEN_H
