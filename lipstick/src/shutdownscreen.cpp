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
#include <QGuiApplication>
#include "homewindow.h"
#include <QQmlContext>
#include <QScreen>
#include "utilities/closeeventeater.h"
#include "notifications/notificationmanager.h"
#include "homeapplication.h"
#include "shutdownscreen.h"
#include "lipstickqmlpath.h"

#include <QDBusConnection>
#include <dsme/dsme_dbus_if.h>
#include <dsme/thermalmanager_dbus_if.h>

ShutdownScreen::ShutdownScreen(QObject *parent) :
    QObject(parent),
    window(0)
{
    QDBusConnection bus = QDBusConnection::systemBus();
    bus.connect(dsme_service, dsme_sig_path, dsme_sig_interface,
                dsme_shutdown_ind, this, SLOT(handleShutdown()));
    bus.connect(dsme_service, dsme_sig_path, dsme_sig_interface,
                dsme_state_req_denied_ind, this, SLOT(handleShutdownDenied(QString,QString)));
    bus.connect(dsme_service, dsme_sig_path, dsme_sig_interface,
                dsme_battery_empty_ind, this, SLOT(handleBatteryEmpty()));
    bus.connect(dsme_service, dsme_sig_path, dsme_sig_interface,
                dsme_state_change_ind, this, SLOT(handleStateChange(QString)));
    bus.connect(thermalmanager_service, thermalmanager_path, thermalmanager_interface,
                thermalmanager_state_change_ind, this, SLOT(handleThermalStateChange(QString)));
}

void ShutdownScreen::setWindowVisible(bool visible)
{
    if (visible) {
        if (window == 0) {
            window = new HomeWindow();
            window->setGeometry(QRect(QPoint(), QGuiApplication::primaryScreen()->size()));
            window->setCategory(QLatin1String("notification"));
            window->setWindowTitle("Shutdown");
            window->setContextProperty("initialSize", QGuiApplication::primaryScreen()->size());
            window->setContextProperty("shutdownScreen", this);
            window->setContextProperty("shutdownMode", shutdownMode);
            window->setSource(QmlPath::to("system/ShutdownScreen.qml"));
            window->installEventFilter(new CloseEventEater(this));
        }

        if (!window->isVisible()) {
            window->show();
            emit windowVisibleChanged();
        }
    } else if (window != 0 && window->isVisible()) {
        window->hide();
        emit windowVisibleChanged();
    }
}

bool ShutdownScreen::windowVisible() const
{
    return window != 0 && window->isVisible();
}

void ShutdownScreen::handleShutdown()
{
    // To avoid early quitting on shutdown
    HomeApplication::instance()->restoreSignalHandlers();
    setWindowVisible(true);
}

void ShutdownScreen::handleShutdownDenied(const QString &reqType, const QString &reason)
{
    if (reason == "usb" && reqType == "shutdown") {
        //% "USB cable plugged in. Unplug it to shut down device."
        createAndPublishNotification("device.added", qtTrId("qtn_shut_unplug_usb"));
    }
}

void ShutdownScreen::handleBatteryEmpty()
{
    //% "Battery empty. Device shutting down."
    createAndPublishNotification("x-nemo.battery.shutdown", qtTrId("qtn_shut_batt_empty"));
}

void ShutdownScreen::handleStateChange(const QString &state)
{
    // Set shutdown mode unless already set explicitly
    if (state == "REBOOT" && shutdownMode.isEmpty()) {
        shutdownMode = "reboot";
        if (window)
            window->setContextProperty("shutdownMode", shutdownMode);
    }
}

void ShutdownScreen::handleThermalStateChange(const QString &state)
{
    if (state == thermalmanager_thermal_status_fatal) {
        //% "Temperature too high. Device shutting down."
        createAndPublishNotification("x-nemo.battery.temperature", qtTrId("qtn_shut_high_temp"));
    }
}

void ShutdownScreen::createAndPublishNotification(const QString &category, const QString &body)
{
    NotificationManager *manager = NotificationManager::instance();
    QVariantHash hints;
    hints.insert(NotificationManager::HINT_CATEGORY, category);
    hints.insert(NotificationManager::HINT_PREVIEW_BODY, body);
    manager->Notify(qApp->applicationName(), 0, QString(), QString(), QString(), QStringList(), hints, -1);
}
