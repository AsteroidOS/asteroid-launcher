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
#include <QQmlContext>
#include <QScreen>
#include <qusbmoded.h>
#include "notifications/notificationmanager.h"
#include "usbmodeselector.h"

QMap<QString, QString> USBModeSelector::errorCodeToTranslationID;

USBModeSelector::USBModeSelector(QObject *parent) :
    QObject(parent),
    usbMode(new QUsbModed(this))
{
    if (errorCodeToTranslationID.isEmpty()) {
        errorCodeToTranslationID.insert("qtn_usb_filessystem_inuse", "qtn_usb_filessystem_inuse");
        errorCodeToTranslationID.insert("mount_failed", "qtn_usb_mount_failed");
    }

    connect(usbMode, SIGNAL(currentModeChanged()), this, SLOT(applyCurrentUSBMode()));
    connect(usbMode, SIGNAL(usbStateError(QString)), this, SLOT(showError(QString)));

    // Lazy initialize to improve startup time
    QTimer::singleShot(500, this, SLOT(applyCurrentUSBMode()));
}

void USBModeSelector::applyCurrentUSBMode()
{
    applyUSBMode(usbMode->currentMode());
}

void USBModeSelector::applyUSBMode(QString mode)
{
    // No mode-selection dialog (usb-moded is configured with a fixed mode,
    // never "ask"); just notify the user which mode the cable activated.
    if (mode != QUsbModed::Mode::Charging &&
        mode != QUsbModed::Mode::Undefined &&
        mode != QUsbModed::Mode::Ask &&
        mode != QUsbModed::Mode::ModeRequest) {
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
