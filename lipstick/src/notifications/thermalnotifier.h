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
#ifndef THERMALNOTIFIER_H
#define THERMALNOTIFIER_H

#include <QObject>
#include <QString>

class QMceDisplay;

class ThermalNotifier : public QObject
{
    Q_OBJECT
public:
    explicit ThermalNotifier(QObject *parent = 0);

private slots:
    /*!
     * Reacts to thermal state changes by showing the
     * related notification.
     *
     * \param state the new thermal state, as reported by DSME's
     * thermal manager ("low", "normal", "warning", "alert", "fatal")
     */
    void applyThermalState(const QString &state);

    /*!
     * Reacts to display state changes by showing the
     * related notification if not displayed yet.
     */
    void applyDisplayState();

private:
    /*!
     * Shows a system notification.
     *
     * \param category the category of the notification
     * \param body the body text of the notification
     */
    void createAndPublishNotification(const QString &category, const QString &body);

    //! For getting the display state
    QMceDisplay *displayState;

    //! The current thermal state as last reported over D-Bus
    QString thermalState;

    //! Thermal state for which a notification has been displayed while the screen was on
    QString thermalStateNotifiedWhileScreenIsOn;
};

#endif // THERMALNOTIFIER_H
