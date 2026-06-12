/***************************************************************************
**
** Copyright (C) 2013, 2014, 2015 Jolla Ltd.
** Contact: Jonni Rainisto <jonni.rainisto@jollamobile.com>
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

#include <QCoreApplication>
#include <QSettings>
#include <QProcess>
#include <QTimer>
#include <QDebug>
#include "devicelock.h"
#include <sys/time.h>
#include <QDBusConnection>
#include <QFile>
#include <QFileInfo>
#include <QDBusMessage>
#include <QDBusConnectionInterface>
#include "homeapplication.h"
#include <mce/dbus-names.h>
#include <mce/mode-names.h>

/** Maximum extra delay when waking up from suspend to apply devicelock */
#define DEVICELOCK_MAX_WAKEUP_DELAY_S 12

namespace {
const char * const settingsFile = "/usr/share/lipstick/devicelock/devicelock_settings.conf";
const char * const lockingKey = "/desktop/nemo/devicelock/automatic_locking";
}

DeviceLock::DeviceLock(QObject * parent) :
    QObject(parent),
    QDBusContext(),
    m_deviceLockState(Undefined),
    m_lockingDelay(-1),
    m_callActive(false),
    m_displayOn(true),
    m_tklockActive(true),
    m_userActivity(true),
    m_verbosityLevel(1),
    m_hbTimer(0),
    m_blankingPause(false),
    m_blankingInhibit(false)
{
    // Note: deviceLockState stays Undefined until init() gets called
    connect(static_cast<HomeApplication *>(qApp), &HomeApplication::homeReady, this, &DeviceLock::init);

    m_hbTimer = new BackgroundActivity(this);
    connect(m_hbTimer, SIGNAL(running()), this, SLOT(lock()));

    trackCallState();
    trackDisplayState();
    trackTklockState();
    trackInactivityState();
    trackBlankingPause();
    trackBlankingInhibit();
}

/** Handle tklock state signal/reply from mce
 */
void DeviceLock::handleTklockStateChanged(const QString &state)
{
    bool active = (state == MCE_TK_LOCKED);

    if (m_tklockActive != active) {
        if (m_verbosityLevel >= 2)
            qDebug() << state;
        m_tklockActive = active;
        setStateAndSetupLockTimer();
    }
}

void DeviceLock::handleTklockStateReply(QDBusPendingCallWatcher *call)
{
    QDBusPendingReply<QString> reply = *call;
    if (reply.isError()) {
        qCritical() << "Call to mce failed:" << reply.error();
    } else {
        handleTklockStateChanged(reply.value());
    }
    call->deleteLater();
}

void DeviceLock::trackTklockState()
{
    QDBusConnection::systemBus().connect(QString(), MCE_SIGNAL_PATH, MCE_SIGNAL_IF, MCE_TKLOCK_MODE_SIG,
                                         this, SLOT(handleTklockStateChanged(QString)));

    QDBusMessage call = QDBusMessage::createMethodCall(MCE_SERVICE, MCE_REQUEST_PATH, MCE_REQUEST_IF, MCE_TKLOCK_MODE_GET);
    QDBusPendingCall reply = QDBusConnection::systemBus().asyncCall(call);
    QDBusPendingCallWatcher *watch = new QDBusPendingCallWatcher(reply, this);
    connect(watch, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(handleTklockStateReply(QDBusPendingCallWatcher*)));
}

/** Handle call state signal/reply from mce
 */
void DeviceLock::handleCallStateChanged(const QString &state)
{
    bool active = (state == MCE_CALL_STATE_ACTIVE ||
                   state == MCE_CALL_STATE_RINGING);

    if (m_callActive != active) {
        if (m_verbosityLevel >= 2)
            qDebug() << state;
        m_callActive = active;
        setStateAndSetupLockTimer();
    }
}

void DeviceLock::handleCallStateReply(QDBusPendingCallWatcher *call)
{
    QDBusPendingReply<QString> reply = *call;
    if (reply.isError()) {
        qCritical() << "Call to mce failed:" << reply.error();
    } else {
        handleCallStateChanged(reply.value());
    }
    call->deleteLater();
}

void DeviceLock::trackCallState()
{
    QDBusConnection::systemBus().connect(QString(), MCE_SIGNAL_PATH, MCE_SIGNAL_IF, MCE_CALL_STATE_SIG,
                                         this, SLOT(handleCallStateChanged(QString)));

    QDBusMessage call = QDBusMessage::createMethodCall(MCE_SERVICE, MCE_REQUEST_PATH, MCE_REQUEST_IF, MCE_CALL_STATE_GET);
    QDBusPendingCall reply = QDBusConnection::systemBus().asyncCall(call);
    QDBusPendingCallWatcher *watch = new QDBusPendingCallWatcher(reply, this);
    connect(watch, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(handleCallStateReply(QDBusPendingCallWatcher*)));
}

/** Handle display state signal/reply from mce
 */
void DeviceLock::handleDisplayStateChanged(const QString &state)
{
    bool displayOn = (state == MCE_DISPLAY_ON_STRING ||
                      state == MCE_DISPLAY_DIM_STRING);

    if (m_displayOn != displayOn) {
        if (m_verbosityLevel >= 2)
            qDebug() << state;
        m_displayOn = displayOn;
        setStateAndSetupLockTimer();
    }
}

void DeviceLock::handleDisplayStateReply(QDBusPendingCallWatcher *call)
{
    QDBusPendingReply<QString> reply = *call;
    if (reply.isError()) {
        qCritical() << "Call to mce failed:" << reply.error();
    } else {
        handleDisplayStateChanged(reply.value());
    }
    call->deleteLater();
}

void DeviceLock::trackDisplayState()
{
    QDBusConnection::systemBus().connect(QString(), MCE_SIGNAL_PATH, MCE_SIGNAL_IF, MCE_DISPLAY_SIG,
                                         this, SLOT(handleDisplayStateChanged(QString)));

    QDBusMessage call = QDBusMessage::createMethodCall(MCE_SERVICE, MCE_REQUEST_PATH, MCE_REQUEST_IF, MCE_DISPLAY_STATUS_GET);
    QDBusPendingCall reply = QDBusConnection::systemBus().asyncCall(call);
    QDBusPendingCallWatcher *watch = new QDBusPendingCallWatcher(reply, this);
    connect(watch, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(handleDisplayStateReply(QDBusPendingCallWatcher*)));
}

/** Handle inactivity state signal/reply from mce
 */
void DeviceLock::handleInactivityStateChanged(const bool state)
{
    bool activity = !state;

    if (m_userActivity != activity) {
        if (m_verbosityLevel >= 2)
            qDebug() << state;
        m_userActivity = activity;
        setStateAndSetupLockTimer();
    }
}

void DeviceLock::handleInactivityStateReply(QDBusPendingCallWatcher *call)
{
    QDBusPendingReply<bool> reply = *call;
    if (reply.isError()) {
        qCritical() << "Call to mce failed:" << reply.error();
    } else {
        handleInactivityStateChanged(reply.value());
    }
    call->deleteLater();
}

void DeviceLock::trackInactivityState(void)
{
    QDBusConnection::systemBus().connect(QString(), MCE_SIGNAL_PATH, MCE_SIGNAL_IF, MCE_INACTIVITY_SIG,
                                         this, SLOT(handleInactivityStateChanged(bool)));

    QDBusMessage call = QDBusMessage::createMethodCall(MCE_SERVICE, MCE_REQUEST_PATH, MCE_REQUEST_IF, MCE_INACTIVITY_STATUS_GET);
    QDBusPendingCall reply = QDBusConnection::systemBus().asyncCall(call);
    QDBusPendingCallWatcher *watch = new QDBusPendingCallWatcher(reply, this);
    connect(watch, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(handleInactivityStateReply(QDBusPendingCallWatcher*)));
}

/** Handle blanking inhibit state signal/reply from mce
 */
void DeviceLock::handleBlankingInhibitChanged(const QString &state)
{
    bool blankingInhibit = (state == MCE_INHIBIT_BLANK_ACTIVE_STRING);
    if (m_blankingInhibit != blankingInhibit) {
        if (m_verbosityLevel >= 2)
            qDebug() << state;
        m_blankingInhibit = blankingInhibit;
        emit blankingInhibitChanged();
    }
}

void DeviceLock::handleBlankingInhibitReply(QDBusPendingCallWatcher *call)
{
    QDBusPendingReply<QString> reply = *call;
    if (reply.isError()) {
        qCritical() << "Call to mce failed:" << reply.error();
    } else {
        handleBlankingInhibitChanged(reply.value());
    }
    call->deleteLater();
}

void DeviceLock::trackBlankingInhibit()
{
    QDBusConnection::systemBus().connect(QString(), MCE_SIGNAL_PATH, MCE_SIGNAL_IF, MCE_BLANKING_INHIBIT_SIG,
                                         this, SLOT(handleBlankingInhibitChanged(QString)));

    QDBusMessage call = QDBusMessage::createMethodCall(MCE_SERVICE, MCE_REQUEST_PATH, MCE_REQUEST_IF, MCE_BLANKING_INHIBIT_GET);
    QDBusPendingCall reply = QDBusConnection::systemBus().asyncCall(call);
    QDBusPendingCallWatcher *inhibitWatcher = new QDBusPendingCallWatcher(reply, this);
    connect(inhibitWatcher, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(handleBlankingInhibitReply(QDBusPendingCallWatcher*)));
}

/** Handle blanking pause state signal/reply from mce
 */
void DeviceLock::handleBlankingPauseChanged(const QString &state)
{
    bool blankingPause = (state == MCE_PREVENT_BLANK_ACTIVE_STRING);
    if (m_blankingPause != blankingPause) {
        if (m_verbosityLevel >= 2)
            qDebug() << state;
        m_blankingPause = blankingPause;
        emit blankingPauseChanged();
    }
}

void DeviceLock::handleBlankingPauseReply(QDBusPendingCallWatcher *call)
{
    QDBusPendingReply<QString> reply = *call;
    if (reply.isError()) {
        qCritical() << "Call to mce failed:" << reply.error();
    } else {
        handleBlankingPauseChanged(reply.value());
    }
    call->deleteLater();
}

void DeviceLock::trackBlankingPause()
{
    QDBusConnection::systemBus().connect(QString(), MCE_SIGNAL_PATH, MCE_SIGNAL_IF, MCE_PREVENT_BLANK_SIG,
                                         this, SLOT(handleBlankingPauseChanged(QString)));

    QDBusMessage call = QDBusMessage::createMethodCall(MCE_SERVICE, MCE_REQUEST_PATH, MCE_REQUEST_IF, MCE_PREVENT_BLANK_GET);
    QDBusPendingCall reply = QDBusConnection::systemBus().asyncCall(call);
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, this);
    connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher*)), SLOT(handleBlankingPauseReply(QDBusPendingCallWatcher*)));
}

/** Helper for producing human readable devicelock state logging
 */
static const char *reprLockState(int state)
{
    switch (state) {
    case DeviceLock::Unlocked:  return "Unlocked";
    case DeviceLock::Locked:    return "Locked";
    case DeviceLock::Undefined: return "Undefined";
    default: break;
    }
    return "Invalid";
}

/** Evaluate initial devicelock state
 */
void DeviceLock::init()
{
    if (QFile(settingsFile).exists() && m_settingsWatcher.addPath(settingsFile)) {
        connect(&m_settingsWatcher, SIGNAL(fileChanged(QString)), this, SLOT(readSettings()));
        readSettings();
    }

    setState((m_lockingDelay<0) ? Unlocked : Locked);
}

/** Evaluate devicelock state we should be in
 */
DeviceLock::LockState DeviceLock::getRequiredLockState()
{
    /* Assume current state is ok */
    LockState requiredState = m_deviceLockState;

    if (m_deviceLockState == Undefined) {
        /* Initial state must be decided by init() */
    } else if (m_lockingDelay < 0) {
        /* Device locking is disabled */
        requiredState = Unlocked;
    } else if (m_lockingDelay == 0 && !m_displayOn) {
        /* Display is off in immediate lock mode */
        requiredState = Locked;
    }

    return requiredState;
}

/** Check if devicelock timer should be running
 */
bool DeviceLock::needLockTimer()
{
    /* Must be currently unlocked */
    if (m_deviceLockState != Unlocked)
        return false;

    /* Must not be disabled or in lock-immediate mode */
    if (m_lockingDelay <= 0)
        return false;

    /* Must not have active call */
    if (m_callActive)
        return false;

    /* Must not be in active use */
    if (m_displayOn && !m_tklockActive && m_userActivity)
        return false;

    return true;
}

/** Evaluate required devicelock state and/or need for timer
 */
void DeviceLock::setStateAndSetupLockTimer()
{
    LockState requiredState = getRequiredLockState();

    if (m_deviceLockState != requiredState) {
        /* We should be in different deviceLockState. Set the state
         * and assume that setState() recurses back here so that we
         * get another chance to deal with the stable state. */
        if (m_verbosityLevel >= 2)
            qDebug("forcing %s instead of %s",
                   reprLockState(requiredState),
                   reprLockState(m_deviceLockState));
        setState(requiredState);
    } else if (needLockTimer()) {
        /* Start devicelock timer */
        if (!m_hbTimer->isWaiting()) {
            int range_lo = m_lockingDelay * 60;
            int range_hi = range_lo + DEVICELOCK_MAX_WAKEUP_DELAY_S;
            if (m_verbosityLevel >= 1)
                qDebug("start devicelock timer (%d-%d s)", range_lo, range_hi);
            m_hbTimer->wait(range_lo, range_hi);
        } else {
            if (m_verbosityLevel >= 2)
                qDebug("devicelock timer already running");
        }
    } else {
        /* Stop devicelock timer */
        if (!m_hbTimer->isStopped()) {
            if (m_verbosityLevel >= 1)
                qDebug("stop devicelock timer");
            m_hbTimer->stop();
        }
    }
}

/** Slot for locking device on timer trigger
 */
void DeviceLock::lock()
{
    if (m_verbosityLevel >= 1)
        qDebug() << "devicelock triggered";

    setState(Locked);

    /* The setState() call should end up terminating/restarting the
     * timer. If that does not happen, it is a bug. Nevertheless, we
     * must not leave an active cpu keepalive session behind. */
    if (m_hbTimer->isRunning()) {
        qWarning("cpu keepalive was not terminated; forcing stop");
        m_hbTimer->stop();
    }

}

int DeviceLock::state() const
{
    return m_deviceLockState;
}

bool  DeviceLock::blankingPause() const
{
    return m_blankingPause;
}

bool DeviceLock::blankingInhibit() const
{
    return m_blankingInhibit;
}

/** Explicitly set devicelock state
 */
void DeviceLock::setState(int state)
{
    if (m_deviceLockState != (LockState)state) {
        if (state == Locked || isPrivileged()) {
            if (m_verbosityLevel >= 1)
                qDebug("%s -> %s",
                       reprLockState(m_deviceLockState),
                       reprLockState(state));
            m_deviceLockState = (LockState)state;
            emit stateChanged(state);
            emit _notifyStateChanged();

            setStateAndSetupLockTimer();
        } else {
            sendErrorReply(QDBusError::AccessDenied,
                           QString("Caller is not in privileged group"));
        }
    }
}

bool DeviceLock::checkCode(const QString &code)
{
    return runPlugin(QStringList() << "--check-code" << code);
}

bool DeviceLock::setCode(const QString &oldCode, const QString &newCode)
{
    return runPlugin(QStringList() << "--set-code" << oldCode << newCode);
}

bool DeviceLock::isSet() {
    return runPlugin(QStringList() << "--is-set" << "lockcode");
}

bool DeviceLock::runPlugin(const QStringList &args)
{
    QSettings settings("/usr/share/lipstick/devicelock/devicelock.conf", QSettings::IniFormat);
    QString pluginName = settings.value("DeviceLock/pluginName").toString();

    if (pluginName.isEmpty()) {
        qWarning("No plugin configuration set in /usr/share/lipstick/devicelock/devicelock.conf");
        return false;
    }

    QProcess process;
    process.start(pluginName, args);
    if (!process.waitForFinished()) {
        qWarning("Plugin did not finish in time");
        return false;
    }

#ifdef DEBUG_DEVICELOCK
    qDebug() << process.readAllStandardOutput();
    qWarning() << process.readAllStandardError();
#endif

    return process.exitCode() == 0;
}

void DeviceLock::readSettings()
{
    QSettings settings(settingsFile, QSettings::IniFormat);
    if (isSet())
        m_lockingDelay = settings.value(lockingKey, "-1").toInt();
    else
        m_lockingDelay = -1;
    setStateAndSetupLockTimer();
}

bool DeviceLock::isPrivileged()
{
    pid_t pid = -1;
    if (!calledFromDBus()) {
        // Local function calls are always privileged
        return true;
    }
    // Get the PID of the calling process
    pid = connection().interface()->servicePid(message().service());
    // The /proc/<pid> directory is owned by EUID:EGID of the process
    QFileInfo info(QString("/proc/%1").arg(pid));
    if (info.group() != "privileged" && info.group() != "disk" && info.owner() != "root") {
        return false;
    }
    return true;
}
