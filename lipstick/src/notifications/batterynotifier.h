/***************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** Copyright (C) 2012-2019 Jolla Ltd.
** Copyright (c) 2019 Open Mobile Platform LLC.
**
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
#ifndef BATTERYNOTIFIER_H
#define BATTERYNOTIFIER_H

#include <QObject>
#include <QTimer>
#include <qmcechargertype.h>
#include <qmcechargerstate.h>
#include <qmcebatterystatus.h>
#include <qmcebatterylevel.h>
#include <qmcepowersavemode.h>
#include <qmcedisplay.h>
#include <qmcetklock.h>
#include <qmcecallstate.h>
#include <qusbmoded.h>

class NotificationManager;
class BackgroundActivity;

/*!
 * Implements the configuration and state for the battery, the power save mode.
 */
class BatteryNotifier : public QObject
{
    Q_OBJECT

public:
    /*!
     * Creates a new battery business logic.
     *
     * \param the parent QObject
     */
    BatteryNotifier(QObject *parent = NULL);

    /*!
     * Destroys the battery business logic.
     */
    virtual ~BatteryNotifier();

private slots:
    void onNotificationClosed(uint id, uint reason);
    void onChargerTypeChanged();
    void onChargerStateChanged();
    void onBatteryStatusChanged();
    void onBatteryLevelChanged();
    void onPowerSaveModeChanged();
    void onDisplayChanged();
    void onTkLockChanged();
    void onCallStateChanged();
    void onTargetUsbModeChanged();
    void onBatteryLowTimeout();
    void onChargingFailureTimeout();
    void onEvaluateStateTimeout();

private:
    enum NotificationType {
        NotificationCharging,
        NotificationChargingComplete,
        NotificationRemoveCharger,
        NotificationChargingNotStarted,
        NotificationRechargeBattery,
        NotificationEnteringPSM,
        NotificationExitingPSM,
        NotificationLowBattery,
        NotificationNotEnoughPower,
        NotificationFirst = NotificationCharging,
        NotificationLast = NotificationNotEnoughPower,
    };

    struct QueuedNotification {
        NotificationType m_type;
        uint m_id;
    };

    struct State {
        QMceChargerType::Type m_chargerType = QMceChargerType::None;
        bool m_chargerState = false;
        QMceBatteryStatus::Status m_batteryStatus = QMceBatteryStatus::Ok;
        int m_batteryLevel = 50;
        int m_minimumBatteryLevel = 0;
        bool m_powerSaveMode = false;
        QMceDisplay::State m_displayState = QMceDisplay::DisplayOn;
        bool m_tkLock = false;
        QMceCallState::State m_callState = QMceCallState::None;
        QMceCallState::Type m_callType = QMceCallState::Normal;
        QString m_usbMode;
        bool m_suppressCharging = false;
    };

    typedef QSet<NotificationType> NotificationTypeSet;
    typedef QList<NotificationType> NotificationTypeList;

    //! Sends a notification based on the notification type
    void sendNotification(BatteryNotifier::NotificationType type);

    //! Removes any active notifications in the given type set
    void removeNotifications(const NotificationTypeSet &toRemove);

    //! Starts the low battery notifier if not already started
    void startLowBatteryNotifier();

    //! Stops the low battery notifier if not already stopped
    void stopLowBatteryNotifier();

    //! Adjust delay for the next repeated low battery warning
    void updateLowBatteryNotifier();

    static bool notificationTriggeringEdge(NotificationType type);
    static bool evaluateNotificationLevel(NotificationType type,
                                          const State &state);
    void evaluateNotificationTriggering(NotificationType type,
                                        const State &previousState,
                                        const State &currentState,
                                        NotificationTypeSet &toRemove,
                                        NotificationTypeList &toSend);
    void updateDerivedProperties();
    void scheduleStateEvaluation();

    QList<QueuedNotification> m_notifications;
    QTimer m_evaluateStateTimer;
    QTimer m_chargingFailureTimer;
    State m_currentState;
    State m_previousState;
    int m_lowBatteryRepeatLevel;
    NotificationManager *m_notificationManager;
    QMceChargerType *m_mceChargerType;
    QMceChargerState *m_mceChargerState;
    QMceBatteryStatus *m_mceBatteryStatus;;
    QMceBatteryLevel *m_mceBatteryLevel;
    QMcePowerSaveMode *m_mcePowerSaveMode;
    QMceDisplay *m_mceDisplay;
    QMceTkLock *m_mceTkLock;
    QMceCallState *m_mceCallState;
    QUsbModed *m_usbModed;
    BackgroundActivity *m_lowBatteryRepeatActivity;
};
#endif
