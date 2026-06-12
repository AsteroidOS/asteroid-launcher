/***************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
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

#ifndef DEVICELOCK_H
#define DEVICELOCK_H

#include <sys/time.h>
#include <QFileSystemWatcher>
#include <QDBusContext>
#include <QDBusPendingCallWatcher>
#include <keepalive/backgroundactivity.h>

class MDConfItem;
class QTimer;

class DeviceLock : public QObject, protected QDBusContext
{
    Q_OBJECT
    Q_ENUMS(LockState)
    Q_PROPERTY(int state READ state WRITE setState NOTIFY _notifyStateChanged)
    Q_PROPERTY(bool blankingPause READ blankingPause NOTIFY blankingPauseChanged)
    Q_PROPERTY(bool blankingInhibit READ blankingInhibit NOTIFY blankingInhibitChanged)

public:
    DeviceLock(QObject *parent = 0);

    enum LockState
    {
        Unlocked = 0,           /*!< Unlocked - The lock is unlocked */
        Locked,                 /*!< Locked - The lock is being used */
        Undefined               /*!< Undefined - The state of the lock is unknown */
    };

    Q_INVOKABLE int state() const;
    Q_INVOKABLE void setState(int state);

    Q_INVOKABLE bool checkCode(const QString &code);
    Q_INVOKABLE bool setCode(const QString &oldCode, const QString &newCode);
    Q_INVOKABLE bool isSet();
    bool blankingPause() const;
    bool blankingInhibit() const;

signals:
    void stateChanged(int state);
    // Signal the property change independently of the dbus signal to enfore the order of emission.
    void _notifyStateChanged();
    void blankingPauseChanged();
    void blankingInhibitChanged();

private slots:
    void init();
    void lock();

    void handleTklockStateChanged(const QString &state);
    void handleTklockStateReply(QDBusPendingCallWatcher *call);

    void handleCallStateChanged(const QString &state);
    void handleCallStateReply(QDBusPendingCallWatcher *call);

    void handleDisplayStateChanged(const QString &state);
    void handleDisplayStateReply(QDBusPendingCallWatcher *call);

    void handleInactivityStateChanged(const bool state);
    void handleInactivityStateReply(QDBusPendingCallWatcher *call);

    void handleBlankingPauseChanged(const QString &state);
    void handleBlankingPauseReply(QDBusPendingCallWatcher *call);

    void handleBlankingInhibitChanged(const QString &state);
    void handleBlankingInhibitReply(QDBusPendingCallWatcher *call);

    void readSettings();

private:
    void trackTklockState();
    void trackCallState();
    void trackDisplayState();
    void trackInactivityState(void);
    void trackBlankingPause();
    void trackBlankingInhibit();

    static bool runPlugin(const QStringList &args);
    void setStateAndSetupLockTimer();
    bool isPrivileged();
    LockState getRequiredLockState();
    bool needLockTimer();

    LockState m_deviceLockState;
    int  m_lockingDelay;
    bool m_callActive;
    bool m_displayOn;
    bool m_tklockActive;
    bool m_userActivity;
    int  m_verbosityLevel;

    BackgroundActivity *m_hbTimer;

    bool m_blankingPause;
    bool m_blankingInhibit;

    QFileSystemWatcher m_settingsWatcher;

#ifdef UNIT_TEST
    friend class Ut_DeviceLock;
#endif
};

#endif // LOCKSERVICE_H
