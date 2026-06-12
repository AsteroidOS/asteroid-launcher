/***************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
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
#include "lipstickcompositor.h"
#include "screenshotservice.h"

#include <QDateTime>
#include <QGuiApplication>
#include <QImage>
#include <QScreen>
#include <QStandardPaths>
#include <QTransform>
#include <private/qquickwindow_p.h>

ScreenshotService::ScreenshotService(QObject *parent) :
    QObject(parent)
{
}

void ScreenshotService::saveScreenshot(const QString &path)
{
    if (LipstickCompositor *compositor = LipstickCompositor::instance()) {
        QImage grab(compositor->quickWindow()->grabWindow());

        int rotation(QGuiApplication::primaryScreen()->angleBetween(Qt::PrimaryOrientation, compositor->topmostWindowOrientation()));
        if (rotation != 0) {
            QTransform xform;
            xform.rotate(rotation);
            grab = grab.transformed(xform, Qt::SmoothTransformation);
        }

        grab.save(path.isEmpty() ? (QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + "/" + QDateTime::currentDateTime().toString("yyyyMMddhhmmss") + ".png") : path, 0, 100);
    }
}
