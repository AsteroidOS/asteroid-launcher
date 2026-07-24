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
#include <QGuiApplication>
#include "homeapplication.h"
#include "shutdownscreen.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusReply>
#include <QTimer>

/*
 * The shutdown screen is driven by systemd-logind's PrepareForShutdown(true)
 * signal, which is emitted for every poweroff/reboot (whether started from the
 * quick panel via login1 or by mce via systemctl). A logind delay inhibitor is
 * held so the compositor has a window to draw the screen before logind proceeds.
 */
namespace {
const QString kLogin1Service   = QStringLiteral("org.freedesktop.login1");
const QString kLogin1Path      = QStringLiteral("/org/freedesktop/login1");
const QString kLogin1Manager   = QStringLiteral("org.freedesktop.login1.Manager");

// How long to keep the delay inhibitor after showing the screen, so the
// compositor has time to draw it before logind proceeds with the shutdown.
const int kInhibitReleaseDelayMs = 1200;
}

ShutdownScreen::ShutdownScreen(QObject *parent) :
    QObject(parent)
{
    QDBusConnection bus = QDBusConnection::systemBus();
    bus.connect(kLogin1Service, kLogin1Path, kLogin1Manager,
                QStringLiteral("PrepareForShutdown"),
                this, SLOT(handlePrepareForShutdown(bool)));

    // Grab a delay inhibitor up front so logind waits for us (up to its
    // InhibitDelayMaxSec) after announcing the shutdown.
    takeShutdownInhibitor();
}

void ShutdownScreen::takeShutdownInhibitor()
{
    QDBusMessage call = QDBusMessage::createMethodCall(
        kLogin1Service, kLogin1Path, kLogin1Manager, QStringLiteral("Inhibit"));
    call << QStringLiteral("shutdown")
         << QStringLiteral("lipstick")
         << QStringLiteral("Display the shutdown screen")
         << QStringLiteral("delay");

    QDBusReply<QDBusUnixFileDescriptor> reply =
        QDBusConnection::systemBus().call(call);
    if (reply.isValid())
        m_inhibitFd = reply.value();
    // If the call fails we simply hold no lock; the screen will still be
    // shown on PrepareForShutdown, just with no guaranteed draw window.
}

void ShutdownScreen::releaseShutdownInhibitor()
{
    // Dropping the last reference closes the fd, which releases the lock and
    // lets logind continue tearing the system down.
    m_inhibitFd = QDBusUnixFileDescriptor();
}

void ShutdownScreen::setWindowVisible(bool visible)
{
    if (visible != m_visible) {
        m_visible = visible;
        emit windowVisibleChanged();
    }
}

bool ShutdownScreen::windowVisible() const
{
    return m_visible;
}

void ShutdownScreen::handlePrepareForShutdown(bool start)
{
    if (!start)
        return;

    showShutdownScreen();

    // Give the compositor a brief moment to render, then release the lock.
    QTimer::singleShot(kInhibitReleaseDelayMs, this,
                       [this]() { releaseShutdownInhibitor(); });
}

void ShutdownScreen::showShutdownScreen()
{
    // To avoid early quitting on shutdown
    HomeApplication::instance()->restoreSignalHandlers();
    setWindowVisible(true);
}
