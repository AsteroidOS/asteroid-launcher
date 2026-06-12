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

#include "connectionselector.h"

#include <QGuiApplication>
#include "homewindow.h"
#include <QQuickItem>
#include <QQmlContext>
#include <QScreen>
#include <QTimer>
#include "utilities/closeeventeater.h"
#include "connectionselector.h"
#include "lipstickqmlpath.h"

ConnectionSelector::ConnectionSelector(QObject *parent) :
    QObject(parent),
    window(0)
{
    QTimer::singleShot(0, this, SLOT(createWindow()));
}

ConnectionSelector::~ConnectionSelector()
{
    delete window;
}

void ConnectionSelector::createWindow()
{
    window = new HomeWindow();
    window->setGeometry(QRect(QPoint(), QGuiApplication::primaryScreen()->size()));
    window->setCategory(QLatin1String("dialog"));
    window->setWindowTitle("Connection");
    window->setContextProperty("connectionSelector", this);
    window->setContextProperty("initialSize", QGuiApplication::primaryScreen()->size());
    window->setSource(QmlPath::to("connectivity/ConnectionSelector.qml"));
    window->installEventFilter(new CloseEventEater(this));
}

void ConnectionSelector::setWindowVisible(bool visible)
{
    if (visible) {
        if (!window->isVisible()) {
            window->showFullScreen();
            emit windowVisibleChanged();
        }
    } else if (window != 0 && window->isVisible()) {
        window->hide();
        emit windowVisibleChanged();
    }
}

bool ConnectionSelector::windowVisible() const
{
    return window != 0 && window->isVisible();
}
