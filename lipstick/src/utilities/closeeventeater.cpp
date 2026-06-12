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

#include "closeeventeater.h"
#include <QEvent>

CloseEventEater::CloseEventEater(QObject *parent) : QObject(parent)
{
}

bool CloseEventEater::eventFilter(QObject *obj, QEvent *event)
{
    if (event->type() == QEvent::Close) {
        event->ignore();
        return true;
    } else {
        return QObject::eventFilter(obj, event);
    }
}
