/***************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** Copyright (C) 2012-2015 Jolla Ltd.
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
#include <qmlocks.h>
#include <qusbmoded.h>
#include "notifications/notificationmanager.h"
#include "usbmodeselector.h"
#include "lipstickqmlpath.h"

QMap<QString, QString> USBModeSelector::errorCodeToTranslationID;

USBModeSelector::USBModeSelector(QObject *parent) :
    QObject(parent),
    window(0),
    usbMode(new QUsbModed(this)),
    locks(new MeeGo::QmLocks(this))
{
    if (errorCodeToTranslationID.isEmpty()) {
        errorCodeToTranslationID.insert("qtn_usb_filessystem_inuse", "qtn_usb_filessystem_inuse");
        errorCodeToTranslationID.insert("mount_failed", "qtn_usb_mount_failed");
    }

    connect(usbMode, SIGNAL(currentModeChanged()), this, SLOT(applyCurrentUSBMode()));
    connect(usbMode, SIGNAL(usbStateError(QString)), this, SLOT(showError(QString)));
    connect(usbMode, SIGNAL(supportedModesChanged()), this, SIGNAL(supportedUSBModesChanged()));

    // Lazy initialize to improve startup time
    QTimer::singleShot(500, this, SLOT(applyCurrentUSBMode()));
}

void USBModeSelector::applyCurrentUSBMode()
{
    applyUSBMode(usbMode->currentMode());
}

void USBModeSelector::setWindowVisible(bool visible)
{
    if (visible) {
        emit dialogShown();

        if (window == 0) {
            window = new HomeWindow();
            window->setGeometry(QRect(QPoint(), QGuiApplication::primaryScreen()->size()));
            window->setCategory(QLatin1String("dialog"));
            window->setWindowTitle("USB Mode");
            window->setContextProperty("initialSize", QGuiApplication::primaryScreen()->size());
            window->setContextProperty("usbModeSelector", this);
            window->setContextProperty("USBMode", usbMode);
            window->setSource(QmlPath::to("connectivity/USBModeSelector.qml"));
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

bool USBModeSelector::windowVisible() const
{
    return window != 0 && window->isVisible();
}

QStringList USBModeSelector::supportedUSBModes() const
{
    return usbMode->supportedModes();
}

void USBModeSelector::applyUSBMode(QString mode)
{
    if (mode == QUsbModed::Mode::Connected) {
        if (locks->getState(MeeGo::QmLocks::Device) == MeeGo::QmLocks::Locked) {
            // When the device lock is on and USB is connected, always pretend that the USB mode selection dialog is shown to unlock the touch screen lock
            emit dialogShown();

            if (usbMode->configMode() != QUsbModed::Mode::Charging) {
                // Show a notification instead if configured USB mode is not charging only.
                NotificationManager *manager = NotificationManager::instance();
                QVariantHash hints;
                hints.insert(NotificationManager::HINT_CATEGORY, "x-nemo.device.locked");
                //% "Unlock device first"
                hints.insert(NotificationManager::HINT_PREVIEW_BODY, qtTrId("qtn_usb_device_locked"));
                manager->Notify(qApp->applicationName(), 0, QString(), QString(), QString(), QStringList(), hints, -1);
                emit showUnlockScreen();
            }
        }
    } else if (mode == QUsbModed::Mode::Ask ||
               mode == QUsbModed::Mode::ModeRequest) {
        setWindowVisible(true);
    } else if (mode != QUsbModed::Mode::Charging &&
               mode != QUsbModed::Mode::Undefined) {
        // Hide the mode selection dialog and show a mode notification
        setWindowVisible(false);
        showNotification(mode);
    }
}

void USBModeSelector::showNotification(QString mode)
{
    static uint prevNotifId = 0;
    QString category;
    QString body;
    if (mode == QUsbModed::Mode::Disconnected) {
        category = "device.removed";
        //% "USB cable disconnected"
        body = qtTrId("qtn_usb_disconnected");
    } else {
        category = "device.added";
        if (mode == QUsbModed::Mode::ConnectionSharing) {
            //% "USB tethering in use"
            body = qtTrId("qtn_usb_connection_sharing_active");
        } else if (mode == QUsbModed::Mode::MTP) {
            //% "MTP mode in use"
            body = qtTrId("qtn_usb_mtp_active");
        } else if (mode == QUsbModed::Mode::MassStorage) {
            //% "Mass storage in use"
            body = qtTrId("qtn_usb_storage_active");
        } else if (mode == QUsbModed::Mode::Developer) {
            //% "SSH mode in use"
            body = qtTrId("qtn_usb_sdk_active");
        } else if (mode == QUsbModed::Mode::PCSuite) {
            //% "Sync-and-connect in use"
            body = qtTrId("qtn_usb_sync_active");
        } else if (mode == QUsbModed::Mode::Adb) {
            //% "ADB mode in use"
            body = qtTrId("qtn_usb_adb_active");
        } else if (mode == QUsbModed::Mode::Diag) {
            //% "Diag mode in use"
            body = qtTrId("qtn_usb_diag_active");
        } else if (mode == QUsbModed::Mode::Host) {
            //% "USB switched to host mode (OTG)"
            body = qtTrId("qtn_usb_host_mode_active");
        } else {
            return;
        }
    }

    NotificationManager *manager = NotificationManager::instance();
    QVariantHash hints;
    hints.insert(NotificationManager::HINT_URGENCY, 3);
    hints.insert(NotificationManager::HINT_CATEGORY, category);
    hints.insert(NotificationManager::HINT_PREVIEW_BODY, body);
    manager->CloseNotification(prevNotifId, NotificationManager::CloseNotificationCalled);
    prevNotifId = manager->Notify(qApp->applicationName(), 0, QString(), QString(), QString(), QStringList(), hints, -1);
}

void USBModeSelector::showError(const QString &errorCode)
{
    if (errorCodeToTranslationID.contains(errorCode)) {
        NotificationManager *manager = NotificationManager::instance();
        QVariantHash hints;
        hints.insert(NotificationManager::HINT_CATEGORY, "device.error");
        //% "USB connection error occurred"
        hints.insert(NotificationManager::HINT_PREVIEW_BODY, qtTrId(errorCodeToTranslationID.value(errorCode).toUtf8().constData()));
        manager->Notify(qApp->applicationName(), 0, QString(), QString(), QString(), QStringList(), hints, -1);
    }
}

void USBModeSelector::setUSBMode(QString mode)
{
    usbMode->setCurrentMode(mode);
}
