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
#include <QCoreApplication>
#include <QStringList>
#include <QTimer>
#include "notificationmanager.h"
#include "lipsticknotification.h"
#include "batterynotifier.h"
#include <time.h>
#include <keepalive/backgroundactivity.h>

// How much slack to include in keepalive wakeup ranges [s]
static const int HEARTBEAT_INTERVAL = 12;

// Delay range for repeating battery low warnings [s]
static const int LOW_BATTERY_INTERVAL_LOW = 30 * 60;
static const int LOW_BATTERY_INTERVAL_HIGH = (LOW_BATTERY_INTERVAL_LOW
                                              + HEARTBEAT_INTERVAL);

// Maximum expected delay between charger connect and start of charging [ms]
static const int CHARGING_FAILURE_DELAY = 3 * 1000;

// Delay between 1st property change notification and state evaluation [ms]
static const int STATE_EVALUATION_DELAY = 100;

BatteryNotifier::BatteryNotifier(QObject *parent)
    : QObject(parent)
    , m_lowBatteryRepeatLevel(0)
    , m_notificationManager(NotificationManager::instance())
    , m_mceChargerType(new QMceChargerType(this))
    , m_mceChargerState(new QMceChargerState(this))
    , m_mceBatteryStatus(new QMceBatteryStatus(this))
    , m_mceBatteryLevel(new QMceBatteryLevel(this))
    , m_mcePowerSaveMode(new QMcePowerSaveMode(this))
    , m_mceDisplay(new QMceDisplay(this))
    , m_mceTkLock(new QMceTkLock(this))
    , m_mceCallState(new QMceCallState(this))
    , m_usbModed(new QUsbModed(this))
    , m_lowBatteryRepeatActivity(new BackgroundActivity(this))
{
    connect(m_notificationManager, &NotificationManager::NotificationClosed,
            this, &BatteryNotifier::onNotificationClosed);
    connect(m_mceChargerType, &QMceChargerType::validChanged,
            this, &BatteryNotifier::onChargerTypeChanged);
    connect(m_mceChargerType, &QMceChargerType::typeChanged,
            this, &BatteryNotifier::onChargerTypeChanged);
    connect(m_mceChargerState, &QMceChargerState::validChanged,
            this, &BatteryNotifier::onChargerStateChanged);
    connect(m_mceChargerState, &QMceChargerState::chargingChanged,
            this, &BatteryNotifier::onChargerStateChanged);
    connect(m_mceBatteryStatus, &QMceBatteryStatus::validChanged,
            this, &BatteryNotifier::onBatteryStatusChanged);
    connect(m_mceBatteryStatus, &QMceBatteryStatus::statusChanged,
            this, &BatteryNotifier::onBatteryStatusChanged);
    connect(m_mceBatteryLevel, &QMceBatteryLevel::validChanged,
            this, &BatteryNotifier::onBatteryLevelChanged);
    connect(m_mceBatteryLevel, &QMceBatteryLevel::percentChanged,
            this, &BatteryNotifier::onBatteryLevelChanged);
    connect(m_mcePowerSaveMode, &QMcePowerSaveMode::validChanged,
            this, &BatteryNotifier::onPowerSaveModeChanged);
    connect(m_mcePowerSaveMode, &QMcePowerSaveMode::activeChanged,
            this, &BatteryNotifier::onPowerSaveModeChanged);
    connect(m_mceDisplay, &QMceDisplay::validChanged,
            this, &BatteryNotifier::onDisplayChanged);
    connect(m_mceDisplay, &QMceDisplay::stateChanged,
            this, &BatteryNotifier::onDisplayChanged);
    connect(m_mceTkLock, &QMceTkLock::validChanged,
            this, &BatteryNotifier::onTkLockChanged);
    connect(m_mceTkLock, &QMceTkLock::lockedChanged,
            this, &BatteryNotifier::onTkLockChanged);
    connect(m_mceCallState, &QMceCallState::validChanged,
            this, &BatteryNotifier::onCallStateChanged);
    connect(m_mceCallState, &QMceCallState::stateChanged,
            this, &BatteryNotifier::onCallStateChanged);
    connect(m_mceCallState, &QMceCallState::typeChanged,
            this, &BatteryNotifier::onCallStateChanged);
    connect(m_usbModed, &QUsbModed::targetModeChanged,
            this, &BatteryNotifier::onTargetUsbModeChanged);

    m_evaluateStateTimer.setInterval(STATE_EVALUATION_DELAY);
    m_evaluateStateTimer.setSingleShot(true);
    connect(&m_evaluateStateTimer, &QTimer::timeout,
            this, &BatteryNotifier::onEvaluateStateTimeout);

    m_chargingFailureTimer.setInterval(CHARGING_FAILURE_DELAY);
    m_chargingFailureTimer.setSingleShot(true);
    connect(&m_chargingFailureTimer, &QTimer::timeout,
            this, &BatteryNotifier::onChargingFailureTimeout);

    m_lowBatteryRepeatActivity->setWakeupRange(LOW_BATTERY_INTERVAL_LOW,
                                               LOW_BATTERY_INTERVAL_HIGH);
    connect(m_lowBatteryRepeatActivity, &BackgroundActivity::running,
            this, &BatteryNotifier::onBatteryLowTimeout);

    scheduleStateEvaluation();
}

BatteryNotifier::~BatteryNotifier()
{
}

void BatteryNotifier::onNotificationClosed(uint id, uint reason)
{
    Q_UNUSED(reason);
    for (QList<QueuedNotification>::iterator queuedNotification = m_notifications.begin();
         queuedNotification != m_notifications.end();) {
        if (queuedNotification->m_id == id)
            queuedNotification = m_notifications.erase(queuedNotification);
        else
            ++queuedNotification;
    }
}

void BatteryNotifier::onChargerTypeChanged()
{
    if (m_mceChargerType->valid()) {
        m_currentState.m_chargerType = m_mceChargerType->type();
        scheduleStateEvaluation();
    }
}

void BatteryNotifier::onChargerStateChanged()
{
    if (m_mceChargerState->valid()) {
        m_currentState.m_chargerState = m_mceChargerState->charging();
        scheduleStateEvaluation();
    }
}

void BatteryNotifier::onBatteryStatusChanged()
{
    if (m_mceBatteryStatus->valid()) {
        m_currentState.m_batteryStatus = m_mceBatteryStatus->status();
        scheduleStateEvaluation();
    }
}

void BatteryNotifier::onBatteryLevelChanged()
{
    if (m_mceBatteryLevel->valid()) {
        m_currentState.m_batteryLevel = m_mceBatteryLevel->percent();
        scheduleStateEvaluation();
    }
}

void BatteryNotifier::onPowerSaveModeChanged()
{
    if (m_mcePowerSaveMode->valid()) {
        m_currentState.m_powerSaveMode = m_mcePowerSaveMode->active();
        scheduleStateEvaluation();
    }
}

void BatteryNotifier::onDisplayChanged()
{
    if (m_mceDisplay->valid()) {
        m_currentState.m_displayState = m_mceDisplay->state();
        scheduleStateEvaluation();
    }
}

void BatteryNotifier::onTkLockChanged()
{
    if (m_mceTkLock->valid()) {
        m_currentState.m_tkLock = m_mceTkLock->locked();
        scheduleStateEvaluation();
    }
}

void BatteryNotifier::onCallStateChanged()
{
    if (m_mceCallState->valid()) {
        m_currentState.m_callState = m_mceCallState->state();
        m_currentState.m_callType = m_mceCallState->type();
        scheduleStateEvaluation();
    }
}

void BatteryNotifier::onTargetUsbModeChanged()
{
    const QString mode(m_usbModed->targetMode());
    if (m_currentState.m_usbMode != mode) {
        m_currentState.m_usbMode = mode;
        scheduleStateEvaluation();
    }
}

void BatteryNotifier::onBatteryLowTimeout()
{
    sendNotification(NotificationLowBattery);
    m_lowBatteryRepeatLevel = m_currentState.m_batteryLevel - 2;
    m_lowBatteryRepeatActivity->wait();
}

void BatteryNotifier::onChargingFailureTimeout()
{
    sendNotification(NotificationChargingNotStarted);
}

void BatteryNotifier::onEvaluateStateTimeout()
{
    NotificationTypeSet toRemove;
    NotificationTypeList toSend;
    updateDerivedProperties();
    for (int type = NotificationFirst; type <= NotificationLast; ++type)
        evaluateNotificationTriggering(static_cast<NotificationType>(type),
                                       m_previousState, m_currentState,
                                       toRemove, toSend);
    removeNotifications(toRemove);
    foreach(NotificationType type, toSend)
        sendNotification(type);
    m_previousState = m_currentState;
    updateLowBatteryNotifier();
}

void BatteryNotifier::scheduleStateEvaluation()
{
    if (!m_evaluateStateTimer.isActive())
        m_evaluateStateTimer.start();
}

void BatteryNotifier::updateDerivedProperties()
{
    /* Update minimum battery level we expect to see while charging.
     *
     * While discharging / doing battery full maintenance charging:
     * -> track current battery level value
     *
     * While charging:
     * -> track maximum battery level value
     *
     * Allow one to two percent drops to make false positives less likely.
     */
    if (m_currentState.m_chargerState == false
        || m_currentState.m_batteryStatus == QMceBatteryStatus::Full
        || m_currentState.m_batteryLevel > m_currentState.m_minimumBatteryLevel)
        m_currentState.m_minimumBatteryLevel = m_currentState.m_batteryLevel - 1;

    /* Suppress / remove charging notifications when it is expected
     * that usb mode selection specific notifications will pop up.
     *
     * Due to dynamic nature of available usb modes, the condition:
     *   "suppress on dynamic mode activation"
     * needs to be implemented in sort of reversed logic:
     *   "suppress when target mode is not one of known built-in modes"
     *
     * Basically:
     *
     * - Undefined (disconnected), Charger (wall charger), Charging
     *   (connected to pc, for charging only): Notifications in
     *   these situatios are handled here -> no suppressing.
     *
     * - ChargingFallback: Shows up when device lock is preventing
     *   either Ask or automatic mode selection -> usb mode handling
     *   will issue "unlock first" notification -> suppress charging
     *   notification to make room for it.
     *
     * - Ask: Mode selection dialog is on screen, for now it is
     *   assumed that it is ok to show charging notification banner
     *   on top of it -> no suppressing
     *
     * - Everything else: Assume it is dynamic mode, that will have
     *   an associated notification from usb mode handling -> suppress
     *   charging notifications
     */
    const QString mode(m_currentState.m_usbMode);
    
    m_currentState.m_suppressCharging = (mode != QUsbMode::Mode::Ask
                                         && mode != QUsbMode::Mode::Charging
                                         && mode != QUsbMode::Mode::Charger);
}

bool BatteryNotifier::notificationTriggeringEdge(BatteryNotifier::NotificationType type)
{
    switch (type) {
    case BatteryNotifier::NotificationRemoveCharger:
        return false;
    default:
        return true;
    }
}

bool BatteryNotifier::evaluateNotificationLevel(BatteryNotifier::NotificationType type,
                                                const BatteryNotifier::State &state)
{
    bool level = false;
    switch (type) {
    case BatteryNotifier::NotificationCharging:
        /* Charging, battery is not full, and we are not expecting
         * usb-mode related notifications. */
        level = (state.m_chargerState == true
                 && state.m_batteryStatus != QMceBatteryStatus::Full
                 && state.m_suppressCharging == false);
        break;
    case BatteryNotifier::NotificationChargingComplete:
        /* Battery is full (implies charging), and we are not
         * expecting usb-mode related notifications. */
        level = (state.m_batteryStatus == QMceBatteryStatus::Full
                 && state.m_suppressCharging == false);
        break;
    case BatteryNotifier::NotificationRechargeBattery:
        /* Battery empty (implies not charging) */
        level = (state.m_batteryStatus == QMceBatteryStatus::Empty);
        break;
    case BatteryNotifier::NotificationLowBattery:
        /* Battery low (implies not charging) */
        level = (state.m_batteryStatus == QMceBatteryStatus::Low);
        break;
    case BatteryNotifier::NotificationRemoveCharger:
        /* Condition is "connected to wall charger", but we trigger
         * on falling edge i.e. on wall charger disconnect. */
        level = (state.m_chargerType == QMceChargerType::DCP
                 || state.m_chargerType == QMceChargerType::HVDCP);
        break;
    case BatteryNotifier::NotificationChargingNotStarted:
        /* Charger is connected, but charging has not commenced
         * within expected time frame. */
        level = (state.m_chargerType != QMceChargerType::None
                 && state.m_chargerState == false);
        break;
    case BatteryNotifier::NotificationEnteringPSM:
        level = (state.m_powerSaveMode == true);
        break;
    case BatteryNotifier::NotificationExitingPSM:
        level = (state.m_powerSaveMode == false);
        break;
    case BatteryNotifier::NotificationNotEnoughPower:
        /* Battery level has dropped since charger was connected. */
        level = (state.m_batteryLevel < state.m_minimumBatteryLevel);
        break;
    }
    return level;
}

void BatteryNotifier::evaluateNotificationTriggering(NotificationType type,
                                                     const State &previousState,
                                                     const State &currentState,
                                                     NotificationTypeSet &toRemove,
                                                     NotificationTypeList &toSend)
{
    bool previousLevel = evaluateNotificationLevel(type, previousState);
    bool currentLevel = evaluateNotificationLevel(type, currentState);
    if (previousLevel != currentLevel) {
        if (currentLevel == notificationTriggeringEdge(type)) {
            switch (type) {
            case NotificationLowBattery:
                startLowBatteryNotifier();
                break;
            case NotificationChargingNotStarted:
                m_chargingFailureTimer.start();
                break;
            case NotificationCharging:
                /* Make sure 'disconnect charger' notification gets
                 * hidden also on connect to pc */
                toRemove << NotificationRemoveCharger;
                toSend << type;
                break;
            default:
                toSend << type;
                break;
            }
        } else {
            switch (type) {
            case NotificationLowBattery:
                stopLowBatteryNotifier();
                break;
            case NotificationChargingNotStarted:
                m_chargingFailureTimer.stop();
                break;
            default:
                break;
            }
            toRemove << type;
        }
    }
}

void BatteryNotifier::sendNotification(BatteryNotifier::NotificationType type)
{
    static const struct NotificationInfo {
        QString category;
        QString message;
        QString icon;
    } description[] = {
        {"x-nemo.battery", // NotificationCharging
         //% "Charging"
         qtTrId("qtn_ener_charging"),
         ""},
        {"x-nemo.battery.chargingcomplete", // NotificationChargingComplete
         //% "Charging complete"
         qtTrId("qtn_ener_charcomp"),
         ""},
        {"x-nemo.battery.removecharger", // NotificationRemoveCharger
         //% "Disconnect charger from power supply to save energy"
         qtTrId("qtn_ener_remcha"),
         ""},
        {"x-nemo.battery.chargingnotstarted", // NotificationChargingNotStarted
         //% "Charging not started. Replace charger."
         qtTrId("qtn_ener_repcharger"),
         ""},
        {"x-nemo.battery.recharge", // NotificationRechargeBattery
         //% "Recharge battery"
         qtTrId("qtn_ener_rebatt"),
         ""},
        {"x-nemo.battery.enterpsm", // NotificationEnteringPSM
         //% "Entering power save mode"
         qtTrId("qtn_ener_ent_psnote"),
         ""},
        {"x-nemo.battery.exitpsm", // NotificationExitingPSM
         //% "Exiting power save mode"
         qtTrId("qtn_ener_exit_psnote"),
         ""},
        {"x-nemo.battery.lowbattery", // NotificationLowBattery
         //% "Low battery"
         qtTrId("qtn_ener_lowbatt"),
         ""},
        {"x-nemo.battery.notenoughpower", // NotificationNotEnoughPower
         //% "Not enough power to charge"
         qtTrId("qtn_ener_nopowcharge"),
         "icon-m-energy-management-insufficient-power"}
    };
    Q_ASSERT(type < sizeof(description) / sizeof(description[0]));
    NotificationInfo const &info = description[type];

    /* Purge any existing notification items of the same type */
    for (QList<QueuedNotification>::iterator queuedNotification = m_notifications.begin();
         queuedNotification != m_notifications.end();) {
        if (queuedNotification->m_type == type) {
            uint id = queuedNotification->m_id;
            queuedNotification = m_notifications.erase(queuedNotification);
            m_notificationManager->CloseNotification(id);
        } else {
            ++queuedNotification;
        }
    }

    /* Add fresh notification item */
    QVariantHash hints;
    hints.insert(NotificationManager::HINT_CATEGORY, info.category);
    hints.insert(NotificationManager::HINT_PREVIEW_BODY, info.message);
    QueuedNotification queuedNotification;
    queuedNotification.m_type = type;
    queuedNotification.m_id = m_notificationManager->Notify(qApp->applicationName(),
                                                            0,
                                                            info.icon,
                                                            QString(),
                                                            QString(),
                                                            QStringList(),
                                                            hints,
                                                            -1);
    m_notifications.push_back(queuedNotification);
}

void BatteryNotifier::removeNotifications(const NotificationTypeSet &toRemove)
{
    for (QList<QueuedNotification>::iterator queuedNotification = m_notifications.begin();
         queuedNotification != m_notifications.end();) {
        if (toRemove.contains(queuedNotification->m_type)) {
            uint id = queuedNotification->m_id;
            queuedNotification = m_notifications.erase(queuedNotification);
            m_notificationManager->CloseNotification(id);
        } else {
            ++queuedNotification;
        }
    }
}

void BatteryNotifier::startLowBatteryNotifier()
{
    m_lowBatteryRepeatActivity->run();
}

void BatteryNotifier::stopLowBatteryNotifier()
{
    m_lowBatteryRepeatActivity->stop();
}

void BatteryNotifier::updateLowBatteryNotifier()
{
    if (m_lowBatteryRepeatActivity->isWaiting()) {
        /* We have ongoing battery low warning repeat cycle */
        bool active = (m_currentState.m_displayState != QMceDisplay::DisplayOff
                       && m_currentState.m_tkLock == false);
        bool incall = m_currentState.m_callState != QMceCallState::None;
        if (active || incall) {
            /* Device is in "active use" */
            if (m_currentState.m_batteryLevel <= m_lowBatteryRepeatLevel) {
                /* Significant battery level drop since the last warning
                 * -> repeat the warning immediately. */
                m_lowBatteryRepeatActivity->run();
            }
        }
    }
}
