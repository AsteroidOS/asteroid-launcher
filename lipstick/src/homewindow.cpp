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

#include "homewindow.h"

#include <QScreen>
#include <QQmlError>
#include <QQuickView>
#include <QQmlContext>
#include <QGuiApplication>
#include "homeapplication.h"
#include "compositor/lipstickcompositorprocwindow.h"
#include "compositor/lipstickcompositor.h"

class HomeWindowPrivate
{
public:
    HomeWindowPrivate();
    ~HomeWindowPrivate();

    enum Mode { Unknown, Compositor, Window };
    static Mode mode;
    static bool isWindow();
    static bool isCompositor();
    static void checkMode();

    bool isVisible:1;
    QString title;
    QString category;
    QRect geometry;
    QQuickWindow *window;
    LipstickCompositorProcWindow *compositorWindow;
    QQmlContext *context;
    QQuickItem *root;
    QList<QQmlError> errors;
};

HomeWindowPrivate::Mode HomeWindowPrivate::mode = HomeWindowPrivate::Unknown;

HomeWindowPrivate::HomeWindowPrivate()
: isVisible(false), window(0), compositorWindow(0), context(0), root(0)
{
    checkMode();
    if (0 == HomeApplication::instance())
        qFatal("HomeWindow: Must create HomeApplication before HomeWindow");

    context = new QQmlContext(HomeApplication::instance()->engine());

    if (isWindow()) {
        window = new QQuickWindow;
        // XXX
        // window->setResizeMode(QQuickView::SizeRootObjectToView);
    } else {
        window = LipstickCompositor::instance()->quickWindow();
    }
}

HomeWindowPrivate::~HomeWindowPrivate()
{
    delete root;
    delete context;
    if (isWindow()) delete window;
}

bool HomeWindowPrivate::isWindow()
{
    if (mode == Unknown) checkMode();
    return mode == Window;
}

bool HomeWindowPrivate::isCompositor()
{
    if (mode == Unknown) checkMode();
    return mode == Compositor;
}

void HomeWindowPrivate::checkMode()
{
    if (mode == Unknown) {
        mode = LipstickCompositor::instance()?Compositor:Window;
        if (mode == Window && qApp->platformName().startsWith("eglfs")) {
            qFatal("HomeWindow: Window mode not supported on eglfs");
        }
    } else if (mode == Window) {
        qWarning("HomeWindow: Compositor appeared after first window");
    }
}

HomeWindow::HomeWindow()
: d(new HomeWindowPrivate)
{
}

HomeWindow::~HomeWindow()
{
    delete d;
}

bool HomeWindow::isVisible() const
{
    return d->isVisible;
}

void HomeWindow::show()
{
    if (d->isVisible)
        return;

    d->isVisible = true;
    if (d->isWindow()) {
        d->window->show();
    } else {
        d->compositorWindow = LipstickCompositor::instance()->mapProcWindow(d->title, d->category, d->geometry, d->root);
        if (d->root) {
            d->root->setParentItem(d->compositorWindow);
        }
    }

    emit visibleChanged(d->isVisible);
}

void HomeWindow::hide()
{
    if (!d->isVisible)
        return;

    d->isVisible = false;
    if (d->isWindow()) {
        d->window->hide();
    } else if (d->compositorWindow) {
        d->compositorWindow->hide();
        d->compositorWindow = 0;
    }

    emit visibleChanged(d->isVisible);
}

void HomeWindow::showFullScreen()
{
    if (d->isVisible)
        return;

    d->isVisible = true;
    if (d->isWindow()) {
        d->window->showFullScreen();
    } else {
        d->compositorWindow = LipstickCompositor::instance()->mapProcWindow(d->title, d->category, d->geometry, d->root);
        if (d->root) {
            d->root->setParentItem(d->compositorWindow);
        }
    }

    emit visibleChanged(d->isVisible);
}

QQuickItem *HomeWindow::rootObject() const
{
    return d->root;
}

void HomeWindow::setSource(const QUrl &source)
{
    d->errors.clear();
    if (d->root) {
        delete d->root;
        d->root = 0;
    }

    QQmlComponent component(d->context->engine(), source);
    if (component.isError()) {
        d->errors = component.errors();
        foreach (const QQmlError &error, d->errors) {
            QMessageLogger(error.url().toString().toLatin1().constData(), error.line(), 0).warning()
                    << error;
        }
        return;
    }

    QObject *o = component.create(d->context);
    if (QQuickItem *item = qobject_cast<QQuickItem *>(o)) {
        d->root = item;

        if (d->isWindow()) {
            item->setParentItem(d->window->contentItem());
        } else if (d->compositorWindow) {
            d->compositorWindow->setRootItem(item);
            item->setParentItem(d->compositorWindow);
        }

    } else {
        delete o;
    }
}

void HomeWindow::setWindowTitle(const QString &title)
{
    d->title = title;
    if (d->isWindow())
        d->window->setTitle(title);
    else if (d->compositorWindow)
        d->compositorWindow->setTitle(title);
}

bool HomeWindow::hasErrors() const
{
    return !d->errors.isEmpty();
}

QString HomeWindow::category() const
{
    return d->category;
}

void HomeWindow::setCategory(const QString &category)
{
    d->category = category;
}

QList<QQmlError> HomeWindow::errors() const
{
    return d->errors;
}

void HomeWindow::resize(const QSize &size)
{
    d->geometry.setSize(size);

    if (d->isWindow())
        d->window->resize(size);
    if (d->root)
        d->root->setSize(size);
}

void HomeWindow::setGeometry(const QRect &g)
{
    d->geometry = g;

    if (d->isWindow()) {
        d->window->setGeometry(g);
        if (d->root) d->root->setSize(g.size());
    } else if (d->root) {
        d->root->setSize(g.size());
        d->root->setPosition(g.topLeft());
    }
}

void HomeWindow::raise()
{
    if (d->isWindow())
        d->window->raise();
    else if (d->compositorWindow)
        LipstickCompositor::instance()->windowRaised(d->compositorWindow);
}

void HomeWindow::lower()
{
    if (d->isWindow())
        d->window->lower();
    else if (d->compositorWindow)
        LipstickCompositor::instance()->windowLowered(d->compositorWindow);
}

QQmlEngine *HomeWindow::engine() const
{
    return HomeApplication::instance()->engine();
}

void HomeWindow::setContextProperty(const QString &property, const QVariant &value)
{
    d->context->setContextProperty(property, value);
}

void HomeWindow::setContextProperty(const QString &property, QObject *value)
{
    d->context->setContextProperty(property, value);
}

