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
#include <QDBusContext>
#include <QDBusConnectionInterface>
#include <QFileInfo>
#include "homewindow.h"
#include <QQmlContext>
#include <QScreen>
#include "utilities/closeeventeater.h"
#include "notifications/notificationmanager.h"
#include "homeapplication.h"
#include "shutdownscreen.h"
#include "lipstickqmlpath.h"

ShutdownScreen::ShutdownScreen(QObject *parent) :
    QObject(parent),
    QDBusContext(),
    window(0),
    systemState(new MeeGo::QmSystemState(this))
{
    connect(systemState, SIGNAL(systemStateChanged(MeeGo::QmSystemState::StateIndication)), this, SLOT(applySystemState(MeeGo::QmSystemState::StateIndication)));
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

void ShutdownScreen::applySystemState(MeeGo::QmSystemState::StateIndication what)
{
    switch (what) {
        case MeeGo::QmSystemState::Shutdown:
            // To avoid early quitting on shutdown
            HomeApplication::instance()->restoreSignalHandlers();
            setWindowVisible(true);
            break;

        case MeeGo::QmSystemState::ThermalStateFatal:
            //% "Temperature too high. Device shutting down."
            createAndPublishNotification("x-nemo.battery.temperature", qtTrId("qtn_shut_high_temp"));
            break;

        case MeeGo::QmSystemState::ShutdownDeniedUSB:
            //% "USB cable plugged in. Unplug it to shut down device."
            createAndPublishNotification("device.added", qtTrId("qtn_shut_unplug_usb"));
            break;

        case MeeGo::QmSystemState::BatteryStateEmpty:
            //% "Battery empty. Device shutting down."
            createAndPublishNotification("x-nemo.battery.shutdown", qtTrId("qtn_shut_batt_empty"));
            break;

        case MeeGo::QmSystemState::Reboot:
            // Set shutdown mode unless already set explicitly
            if (shutdownMode.isEmpty()) {
                shutdownMode = "reboot";
                window->setContextProperty("shutdownMode", shutdownMode);
            }
            break;

        default:
            break;
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

void ShutdownScreen::setShutdownMode(const QString &mode)
{
    if (!isPrivileged())
        return;

    shutdownMode = mode;
    applySystemState(MeeGo::QmSystemState::Shutdown);
}

bool ShutdownScreen::isPrivileged()
{
    if (!calledFromDBus()) {
        // Local function calls are always privileged
        return true;
    }

    // Get the PID of the calling process
    pid_t pid = connection().interface()->servicePid(message().service());

    // The /proc/<pid> directory is owned by EUID:EGID of the process
    QFileInfo info(QString("/proc/%1").arg(pid));
    if (info.group() != "privileged" && info.owner() != "root") {
        sendErrorReply(QDBusError::AccessDenied,
                QString("PID %1 is not in privileged group").arg(pid));
        return false;
    }

    return true;
}
