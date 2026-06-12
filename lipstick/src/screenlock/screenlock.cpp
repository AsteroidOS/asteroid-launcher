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

#include <QTimer>
#include <QDBusInterface>
#include <QDBusPendingCall>
#include <QTextStream>
#include <QCursor>
#include <QDebug>

#include <mce/mode-names.h>
#include <qmdisplaystate.h>

#include "homeapplication.h"
#include "screenlock.h"
#include "utilities/closeeventeater.h"

ScreenLock::ScreenLock(QObject* parent) :
    QObject(parent),
    callbackInterface(NULL),
    shuttingDown(false),
    lockscreenVisible(false),
    eatEvents(false),
    lowPowerMode(false),
    mceBlankingPolicy("default")
{
    // No explicit API in tklock for disabling event eater. Monitor display
    // state changes, and remove event eater if display becomes undimmed.
    MeeGo::QmDisplayState *displayState = new MeeGo::QmDisplayState(this);
    connect(displayState, &MeeGo::QmDisplayState::displayStateChanged,
            this, &ScreenLock::handleDisplayStateChange);

    qApp->installEventFilter(this);

    auto systemBus = QDBusConnection::systemBus();
    systemBus.connect(QString(),
            "/com/nokia/mce/signal",
            "com.nokia.mce.signal",
            "lpm_ui_mode_ind",
            this,
            SLOT(handleLpmModeChange(QString)));
    systemBus.connect(QString(),
            "/com/nokia/mce/signal",
            "com.nokia.mce.signal",
            "display_blanking_policy_ind",
            this,
            SLOT(handleBlankingPolicyChange(QString)));
}

ScreenLock::~ScreenLock()
{
}

int ScreenLock::tklock_open(const QString &service, const QString &path, const QString &interface, const QString &method, uint mode, bool, bool)
{
    if (shuttingDown) {
        // Don't show the touch screen lock while shutting down
        return TkLockReplyOk;
    }

    // Create a D-Bus interface if one doesn't exist or the D-Bus callback details have changed
    if (callbackInterface == NULL || callbackInterface->service() != service || callbackInterface->path() != path || callbackInterface->interface() != interface) {
        delete callbackInterface;
        callbackInterface = new QDBusInterface(service, path, interface, QDBusConnection::systemBus(), this);
    }

    // Store the callback method name
    callbackMethod = method;

    // MCE needs a response ASAP, so the actions are executed with single shot timers
    switch (mode) {
    case TkLockModeEnable:
        // Create the lock screen already so that it's readily available
        QTimer::singleShot(0, this, SLOT(showScreenLock()));
        break;

    case TkLockModeOneInput:
        QTimer::singleShot(0, this, SLOT(showEventEater()));
        break;

    case TkLockEnableVisual:
        // Raise the lock screen window on top if it isn't already
        QTimer::singleShot(0, this, SLOT(showScreenLock()));
        break;

    case TkLockEnableLowPowerMode:
        // Raise the lock screen window on top if it isn't already
        // (XXX: Low power mode is now handled via lpm_ui_mode_ind)
        QTimer::singleShot(0, this, SLOT(showLowPowerMode()));
        break;

    case TkLockRealBlankMode:
        QTimer::singleShot(0, this, SLOT(setDisplayOffMode()));
        break;

    default:
        break;
    }

    return TkLockReplyOk;
}

int ScreenLock::tklock_close(bool)
{
    QTimer::singleShot(0, this, SLOT(hideScreenLock()));

    return TkLockReplyOk;
}

void ScreenLock::lockScreen(bool immediate)
{
    QDBusMessage message = QDBusMessage::createMethodCall("com.nokia.mce", "/com/nokia/mce/request", "com.nokia.mce.request", "req_tklock_mode_change");
    message.setArguments(QVariantList() << (immediate ? MCE_TK_LOCKED : MCE_TK_LOCKED_DELAY));
    QDBusConnection::systemBus().asyncCall(message);

    showScreenLock();
}

void ScreenLock::unlockScreen()
{
    hideScreenLockAndEventEater();

    if (callbackInterface != NULL && !callbackMethod.isEmpty()) {
        callbackInterface->call(QDBus::NoBlock, callbackMethod, TkLockUnlock);
    }
}

void ScreenLock::showScreenLock()
{
    toggleScreenLockUI(true);
    toggleEventEater(false);
}

void ScreenLock::showLowPowerMode()
{
    toggleScreenLockUI(true);
    toggleEventEater(false);
}

void ScreenLock::setDisplayOffMode()
{
    toggleScreenLockUI(true);
    toggleEventEater(false);
}

void ScreenLock::hideScreenLock()
{
    toggleScreenLockUI(false);
}

void ScreenLock::hideScreenLockAndEventEater()
{
    toggleScreenLockUI(false);
    toggleEventEater(false);
}

void ScreenLock::showEventEater()
{
    toggleEventEater(true);
}

void ScreenLock::hideEventEater()
{
    toggleEventEater(false);
}

void ScreenLock::handleDisplayStateChange(int displayState)
{
    MeeGo::QmDisplayState::DisplayState state = static_cast<MeeGo::QmDisplayState::DisplayState>(displayState);
    if (state == MeeGo::QmDisplayState::Dimmed)
        return;

    // Eating an event is meaningful only when the display is dimmed
    hideEventEater();
}

void ScreenLock::toggleScreenLockUI(bool toggle)
{
    // TODO Make the view a lock screen view (title? stacking layer?)
    if (lockscreenVisible != toggle) {
        lockscreenVisible = toggle;
        emit screenIsLocked(toggle);
    }
}

void ScreenLock::toggleEventEater(bool toggle)
{
    eatEvents = toggle;
}

bool ScreenLock::isScreenLocked() const
{
    return lockscreenVisible;
}

bool ScreenLock::eventFilter(QObject *, QEvent *event)
{
    bool eat = eatEvents && (event->type() == QEvent::MouseButtonPress || event->type() == QEvent::TouchBegin || event->type() == QEvent::TouchUpdate || event->type() == QEvent::TouchEnd);

    if (eat) {
        hideEventEater();
    }

    return eat;
}

bool ScreenLock::isLowPowerMode() const
{
    return lowPowerMode;
}

QString ScreenLock::blankingPolicy() const
{
    return mceBlankingPolicy;
}

void ScreenLock::handleLpmModeChange(const QString &state)
{
    bool enabled = (state == "enabled");

    if (!enabled && state != "disabled") {
        qWarning() << "Invalid LPM state value from mce:" << state;
    }

    if (lowPowerMode != enabled) {
        lowPowerMode = enabled;
        emit lowPowerModeChanged();
    }
}

void ScreenLock::handleBlankingPolicyChange(const QString &policy)
{
    if (mceBlankingPolicy != policy) {
        mceBlankingPolicy = policy;
        emit blankingPolicyChanged(mceBlankingPolicy);
    }
}
