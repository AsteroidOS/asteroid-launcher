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

#ifndef SCREENLOCK_H
#define SCREENLOCK_H

#include <QObject>

class QDBusInterface;

/*!
 * The screen lock business logic is responsible for showing and hiding
 * the screen lock window and the event eater window when necessary.
 */
class ScreenLock : public QObject
{
    Q_OBJECT

public:
    /*!
     * Constructs a new screen lock business logic.
     *
     * \param parent the parent QObject for the logic
     */
    ScreenLock(QObject *parent = NULL);

    /*!
     * Destroys the screen lock business logic.
     */
    virtual ~ScreenLock();

    /*!
     * Shows the screen lock window or the event eater window.
     *
     * \param service DBus service to call when unlock is performed.
     * \param path DBus path to call when unlock is performed.
     * \param interface DBus interface to call when unlock is performed.
     * \param method DBus method to call when unlock is performed.
     * \param mode The ScreenLockBusinessLogicAdaptor::TkLockMode opcode.
     * \param silent Whether to show a notification or not (deprecated)
     * \param flicker Deprecated/not used
     */
    int tklock_open(const QString &service, const QString &path, const QString &interface, const QString &method, uint mode, bool silent, bool flicker);

    /*!
     * Hides the screen lock.
     *
     * \param silent Whether to show notifications or not (deprecated).
     */
    int tklock_close(bool silent);

    /*!
     * Retuns the screen lock state.
     *
     * \return \c true if the screen is locked, \c false otherwise
     */
    bool isScreenLocked() const;

    /*!
     * Returns the low power mode state.
     *
     * \return \c true if the low power mode is on, \c false otherwise
     */
    bool isLowPowerMode() const;

    /*!
     * Returns the blanking policy state
     *
     * \return The blanking policy, which is one of notification, alarm
     * call, linger, or default
     */
    QString blankingPolicy() const;

    //! \reimp
    virtual bool eventFilter(QObject *, QEvent *event);
    //! \reimp_end

public slots:
    //! Shows the screen lock window and calls the MCE's lock function.
    void lockScreen(bool immediate = false);

    //! Hides the screen lock window and calls the MCE's unlock callback function.
    void unlockScreen();

private slots:
    //! Shows or hides the screen lock window
    void toggleScreenLockUI(bool toggle);

    //! Shows or hides the event eater window
    void toggleEventEater(bool toggle);

    //! Shows the screen lock window in normal mode and hides the event eater window.
    void showScreenLock();

    //! Shows the screen lock window in low power mode and hides the event eater window.
    void showLowPowerMode();

    //! Sets the screen lock extensions into display off state
    void setDisplayOffMode();

    //! Hides the screen lock window.
    void hideScreenLock();

    //! Hides the event eater window and the screen lock window.
    void hideScreenLockAndEventEater();

    //! Shows the event eater window.
    void showEventEater();

    //! Hides the event eater window.
    void hideEventEater();

    //! Clear event eater if display is no longer dimmed
    void handleDisplayStateChange(int displayState);

    //! Handles LPM events coming from mce.
    void handleLpmModeChange(const QString &state);

    //! Handles blanking policy change signals from mce
    void handleBlankingPolicyChange(const QString &policy);

signals:
    //! Emitted when the screen lock state changes
    void screenIsLocked(bool locked);

    //! Emitted when the low power mode state changes
    void lowPowerModeChanged();

    //! Emitted when the display blanking policy changes
    void  blankingPolicyChanged(const QString &policy);

private:
    enum TkLockReply {
        TkLockReplyFailed = 0,
        TkLockReplyOk
    };

    enum TkLockMode {
        TkLockModeNone,           // Deprecated
        TkLockModeEnable,         // Show the lock UI in lock mode
        TkLockModeHelp,           // Deprecated
        TkLockModeSelect,         // Deprecated
        TkLockModeOneInput,       // Turn the event eater on
        TkLockEnableVisual,       // Show unlock UI
        TkLockEnableLowPowerMode, // Show low power UI
        TkLockRealBlankMode       // Display completely off
    };

    enum TkLockStatus {
        TkLockUnlock = 1,
        TkLockRetry,
        TkLockTimeout,
        TkLockClosed
    };

    //! MCE callback D-Bus interface
    QDBusInterface *callbackInterface;

    //! Name of the MCE callback method
    QString callbackMethod;

    //! Whether the system is shutting down or not
    bool shuttingDown;

    //! Whether the lockscreen is visible or not
    bool lockscreenVisible;

    //! Whether events should be eaten or not
    bool eatEvents;

    //! Whether the lockscreen should be shown as low power mode
    bool lowPowerMode;

    //! The current blanking policy obtained from mce
    QString mceBlankingPolicy;

#ifdef UNIT_TEST
    friend class Ut_ScreenLock;
#endif
};

#endif
