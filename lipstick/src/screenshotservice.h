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
#ifndef SCREENSHOTSERVICE_H
#define SCREENSHOTSERVICE_H

#include <QObject>

class ScreenshotService : public QObject
{
    Q_OBJECT
public:
    explicit ScreenshotService(QObject *parent = 0);

public slots:
    void saveScreenshot(const QString &path);
};

#endif // SCREENSHOTSERVICE_H
