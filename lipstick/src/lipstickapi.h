/***************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Aaron Kennedy <aaron.kennedy@jollamobile.com>
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

#ifndef LIPSTICKAPI_H
#define LIPSTICKAPI_H

#include <QObject>
#include "lipstickglobal.h"

class LIPSTICK_EXPORT LipstickApi : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    Q_PROPERTY(QObject *compositor READ compositor CONSTANT)

public:
    LipstickApi(QObject *parent = 0);

    bool active() const;
    QObject *compositor() const;

    Q_INVOKABLE void takeScreenshot(const QString &path = QString());

signals:
    void activeChanged();
};

#endif // LIPSTICKAPI_H
