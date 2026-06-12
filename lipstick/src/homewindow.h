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

#ifndef HOMEWINDOW_H
#define HOMEWINDOW_H

#include <QObject>
#include "lipstickglobal.h"

class QQmlError;
class QQmlEngine;
class QQuickItem;
class QQuickView;
class HomeWindowPrivate;

class LIPSTICK_EXPORT HomeWindow : public QObject
{
    Q_OBJECT
public:
    HomeWindow();
    ~HomeWindow();

    bool isVisible() const;
    void show();
    void hide();
    void showFullScreen();
    void raise();
    void lower();

    QQuickItem *rootObject() const;
    void setSource(const QUrl &);
    void setWindowTitle(const QString &);
    bool hasErrors() const;
    QList<QQmlError> errors() const;

    QString category() const;
    void setCategory(const QString &category);

    void resize(const QSize &);
    void setGeometry(const QRect &);

    QQmlEngine *engine() const;
    void setContextProperty(const QString &, const QVariant &);
    void setContextProperty(const QString &, QObject *);

signals:
    void visibleChanged(bool arg);

private:
    HomeWindowPrivate *d;
};

#endif // HOMEWINDOW_H
