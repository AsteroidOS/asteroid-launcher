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
#ifndef USBMODESELECTOR_H
#define USBMODESELECTOR_H

#include <QObject>
#include <QMap>
#include <QStringList>

class QUsbModed;

class USBModeSelector : public QObject
{
    Q_OBJECT

public:

    explicit USBModeSelector(QObject *parent = 0);

private slots:
    /*!
     * Shows the USB dialog/banners based on the given USB mode.
     *
     * \param mode the USB mode to show UI elements for
     */
    void applyUSBMode(QString mode);

    /*!
     * Shows an error string matching the given error code, if any.
     *
     * \param errorCode the error code of the error to be shown
     */
    void showError(const QString &errorCode);

    /*!
     * Shows the USB dialog/banners based on the current USB mode.
     */
    void applyCurrentUSBMode();

private:

    /*!
     * Shows a notification.
     *
     * \param mode the USB mode for the notification
     */
    void showNotification(QString mode);

private:

    //! Error code to translation ID mapping
    static QMap<QString, QString> errorCodeToTranslationID;

    //! For getting the USB mode
    QUsbModed *usbMode;

#ifdef UNIT_TEST
    friend class Ut_USBModeSelector;
#endif
};

#endif // USBMODESELECTOR_H
