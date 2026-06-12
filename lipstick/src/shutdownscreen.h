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
#include <QDBusContext>
#include "lipstickglobal.h"
#include <qmsystemstate.h>

class HomeWindow;

class LIPSTICK_EXPORT ShutdownScreen : public QObject, protected QDBusContext
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

    /*!
     * Sets the shutdown mode for showing the shutdown screen.
     *
     * \param mode a UI frontend specific shutdown mode identifier
     */
    void setShutdownMode(const QString &mode);

signals:
    //! Sent when the visibility of the window has changed.
    void windowVisibleChanged();

private slots:
    /*!
     * Reacts to system state changes by showing the shutdown screen or a
     * related notification.
     *
     * \param what how the system state has changed
     */
    void applySystemState(MeeGo::QmSystemState::StateIndication what);

private:
    /*!
     * Shows a system notification.
     *
     * \param category the category of the notification
     * \param body the body text of the notification
     */
    void createAndPublishNotification(const QString &category, const QString &body);

    //! The volume control window
    HomeWindow *window;

    //! For getting the system state
    MeeGo::QmSystemState *systemState;

    //! The shutdown mode to be communicated to the UI
    QString shutdownMode;

#ifdef UNIT_TEST
    friend class Ut_ShutdownScreen;
#endif

    bool isPrivileged();
};

#endif // SHUTDOWNSCREEN_H
