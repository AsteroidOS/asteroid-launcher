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

ThermalNotifier::ThermalNotifier(QObject *parent) :
    QObject(parent),
    thermalState(new MeeGo::QmThermal(this)),
    displayState(new MeeGo::QmDisplayState(this)),
    thermalStateNotifiedWhileScreenIsOn(MeeGo::QmThermal::Normal)
{
    connect(thermalState, SIGNAL(thermalChanged(MeeGo::QmThermal::ThermalState)), this, SLOT(applyThermalState(MeeGo::QmThermal::ThermalState)));
    connect(displayState, SIGNAL(displayStateChanged(MeeGo::QmDisplayState::DisplayState)), this, SLOT(applyDisplayState(MeeGo::QmDisplayState::DisplayState)));
}

void ThermalNotifier::applyThermalState(MeeGo::QmThermal::ThermalState state)
{
    switch (state) {
    case MeeGo::QmThermal::Warning:
        //% "Device getting hot. Close all apps."
        createAndPublishNotification("x-nemo.battery.temperature", qtTrId("qtn_shut_high_temp_warning"));
        break;
    case MeeGo::QmThermal::Alert:
        //% "Device overheating. Turn it off."
        createAndPublishNotification("x-nemo.battery.temperature", qtTrId("qtn_shut_high_temp_alert"));
        break;
    case MeeGo::QmThermal::LowTemperatureWarning:
        //% "The device is too cold"
        createAndPublishNotification("x-nemo.battery.temperature", qtTrId("qtn_shut_low_temp_warning"));
        break;
    default:
        break;
    }

    if (displayState->get() != MeeGo::QmDisplayState::Off) {
        thermalStateNotifiedWhileScreenIsOn = state;
    }
}

void ThermalNotifier::applyDisplayState(MeeGo::QmDisplayState::DisplayState state)
{
    if (state == MeeGo::QmDisplayState::On) {
        MeeGo::QmThermal::ThermalState currentThermalState = thermalState->get();
        if (thermalStateNotifiedWhileScreenIsOn != currentThermalState) {
            applyThermalState(currentThermalState);
        }
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
