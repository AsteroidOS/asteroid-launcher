/***************************************************************************
**
** Copyright (C) 2012-2014 Jolla Ltd.
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
#include "notifications/notificationmanager.h"
#include "homeapplication.h"
#include "thermalnotifier.h"

#include <QDBusConnection>
#include <qmcedisplay.h>
#include <dsme/thermalmanager_dbus_if.h>

ThermalNotifier::ThermalNotifier(QObject *parent) :
    QObject(parent),
    displayState(new QMceDisplay(this)),
    thermalState(thermalmanager_thermal_status_normal),
    thermalStateNotifiedWhileScreenIsOn(thermalmanager_thermal_status_normal)
{
    QDBusConnection::systemBus().connect(thermalmanager_service,
                                         thermalmanager_path,
                                         thermalmanager_interface,
                                         thermalmanager_state_change_ind,
                                         this, SLOT(applyThermalState(QString)));
    connect(displayState, &QMceDisplay::stateChanged,
            this, &ThermalNotifier::applyDisplayState);
}

void ThermalNotifier::applyThermalState(const QString &state)
{
    thermalState = state;

    if (state == thermalmanager_thermal_status_warning) {
        //% "Device getting hot. Close all apps."
        createAndPublishNotification("x-nemo.battery.temperature", qtTrId("qtn_shut_high_temp_warning"));
    } else if (state == thermalmanager_thermal_status_alert) {
        //% "Device overheating. Turn it off."
        createAndPublishNotification("x-nemo.battery.temperature", qtTrId("qtn_shut_high_temp_alert"));
    } else if (state == thermalmanager_thermal_status_low) {
        //% "The device is too cold"
        createAndPublishNotification("x-nemo.battery.temperature", qtTrId("qtn_shut_low_temp_warning"));
    }

    if (displayState->state() != QMceDisplay::DisplayOff) {
        thermalStateNotifiedWhileScreenIsOn = state;
    }
}

void ThermalNotifier::applyDisplayState()
{
    if (displayState->state() == QMceDisplay::DisplayOn &&
            thermalStateNotifiedWhileScreenIsOn != thermalState) {
        applyThermalState(thermalState);
    }
}

void ThermalNotifier::createAndPublishNotification(const QString &category, const QString &body)
{
    NotificationManager *manager = NotificationManager::instance();
    QVariantHash hints;
    hints.insert(NotificationManager::HINT_CATEGORY, category);
    hints.insert(NotificationManager::HINT_PREVIEW_BODY, body);
    manager->Notify(qApp->applicationName(), 0, QString(), QString(), QString(), QStringList(), hints, -1);
}
