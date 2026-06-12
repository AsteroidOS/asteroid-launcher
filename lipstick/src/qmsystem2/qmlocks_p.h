/*!
 * @file qmlocks_p.h
 * @brief Contains QmLocksPrivate

   <p>
   Copyright (C) 2009-2011 Nokia Corporation

   @author Timo Olkkonen <ext-timo.p.olkkonen@nokia.com>
   @author Matias Muhonen <ext-matias.muhonen@nokia.com>

   @scope Private

   This file is part of SystemSW QtAPI.

   SystemSW QtAPI is free software; you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License
   version 2.1 as published by the Free Software Foundation.

   SystemSW QtAPI is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with SystemSW QtAPI.  If not, see <http://www.gnu.org/licenses/>.
   </p>
 */

#ifndef QMLOCKS_P_H
#define QMLOCKS_P_H

#include "qmlocks.h"

#include <QDBusInterface>
#include <QDBusPendingCall>
#include <QDBusReply>
#include <QMutex>

#include "mce/dbus-names.h"
#include "mce/mode-names.h"

#include "qmipcinterface_p.h"

// The DBus system service provided by devicelock
#define DEVLOCK_SERVICE "org.nemomobile.lipstick"
// The interface that the devicelock uses
#define DEVLOCK_INTERFACE "org.nemomobile.lipstick.devicelock"
// The DBus path of the service
#define DEVLOCK_PATH "/devicelock"
// Method used to determine the state of the devicelock
#define DEVLOCK_GET "state"
// Method used to set the state of the devicelock
#define DEVLOCK_SET "setState"
// A DBus signal used to notify that the state of hte lock has changed
#define DEVLOCK_SIGNAL "stateChanged"

#define DEVLOCK_LOCK_STATE_UNLOCKED 0
#define DEVLOCK_LOCK_STATE_LOCKED 1
#define DEVLOCK_LOCK_STATE_UNDEFINED 2

#define SIGNAL_LOCK_STATE 0

namespace MeeGo
{
    class QmLocksPrivate : public QObject
    {
        Q_OBJECT;
        MEEGO_DECLARE_PUBLIC(QmLocks)

    public:
        QmLocksPrivate() :
            mceRequestIf(0),
            devlockIf(0) {
            mceRequestIf = new QmIPCInterface(MCE_SERVICE, MCE_REQUEST_PATH, MCE_REQUEST_IF);
            devlockIf = new QmIPCInterface(DEVLOCK_SERVICE, DEVLOCK_PATH, DEVLOCK_INTERFACE);

            connectCount[SIGNAL_LOCK_STATE] = 0;
        }

        ~QmLocksPrivate() {
            if (mceRequestIf) {
                delete mceRequestIf, mceRequestIf = 0;
            }
            if (devlockIf) {
                delete devlockIf, devlockIf = 0;
            }
        }

        static QmLocks::State stringToState(const QString &state) {
            if (state == MCE_TK_LOCKED) {
                return QmLocks::Locked;
            } else if (state == MCE_TK_UNLOCKED) {
                return QmLocks::Unlocked;
            }
            return QmLocks::Unknown;
        }

        static QString stateToString(QmLocks::Lock what, QmLocks::State state) {
            if (what == QmLocks::TouchAndKeyboard) {
                if (state == QmLocks::Locked) {
                    return MCE_TK_LOCKED;
                } else if (state == QmLocks::Unlocked) {
                    return MCE_TK_UNLOCKED;
                }
            }
            return "";
        }

        static QmLocks::State stateToState(int state) {
            switch (state) {
            case DEVLOCK_LOCK_STATE_UNLOCKED:
                return QmLocks::Unlocked;
            case DEVLOCK_LOCK_STATE_LOCKED:
                return QmLocks::Locked;
            default:
                return QmLocks::Unknown;
            }
        }

        static int stateToState(QmLocks::State state) {
            switch (state) {
            case QmLocks::Unlocked:
                return DEVLOCK_LOCK_STATE_UNLOCKED;
            case QmLocks::Locked:
                return DEVLOCK_LOCK_STATE_LOCKED;
            default:
                return DEVLOCK_LOCK_STATE_UNDEFINED;
            }
        }

        QmLocks::State getState(QmLocks::Lock what) {
            QmLocks::State state = QmLocks::Unknown;

            if (what == QmLocks::Device) {
                QDBusReply<int> reply = devlockIf->call(DEVLOCK_GET);
                if (reply.isValid()) {
                    state = QmLocksPrivate::stateToState(reply.value());
                }
            } else if (what == QmLocks::TouchAndKeyboard) {
                QDBusReply<QString> reply = mceRequestIf->call(MCE_TKLOCK_MODE_GET);
                if (reply.isValid()) {
                    state = QmLocksPrivate::stringToState(reply.value());
                }
            }
            return state;
        }

        bool setState(QmLocks::Lock what, QmLocks::State how) {
            bool success = false;
            if (what == QmLocks::Device) {
                devlockIf->callAsynchronously(DEVLOCK_SET, stateToState(how));
                success = true;
            } else if (what == QmLocks::TouchAndKeyboard) {
                mceRequestIf->callAsynchronously(MCE_TKLOCK_MODE_CHANGE_REQ, QmLocksPrivate::stateToString(what, how));
                success = true;
            }
            return success;
        }

        QMutex connectMutex;
        size_t connectCount[1];
        QmIPCInterface *mceRequestIf;
        QmIPCInterface *devlockIf;

    Q_SIGNALS:
        void stateChanged(MeeGo::QmLocks::Lock what, MeeGo::QmLocks::State how);

    private Q_SLOTS:

        void didReceiveDeviceLockState(QDBusPendingCallWatcher *call) {
            QDBusPendingReply<int> reply = *call;
            if (reply.isError()) {
                return;
            }
            int state = reply.argumentAt<0>();
            emit stateChanged(QmLocks::Device, stateToState(state));
            call->deleteLater();
        }

        void didReceiveTkLockState(QDBusPendingCallWatcher *call) {
            QDBusPendingReply<QString> reply = *call;
            if (reply.isError()) {
                return;
            }
            QString state = reply.argumentAt<0>();
            emit stateChanged(QmLocks::TouchAndKeyboard, stringToState(state));
            call->deleteLater();
        }

        void deviceStateChanged(int state) {
            emit stateChanged(QmLocks::Device, stateToState(state));
        }

        void touchAndKeyboardStateChanged(const QString& state) {
            emit stateChanged(QmLocks::TouchAndKeyboard, stringToState(state));
        }
    };
}
#endif // QMLOCKS_P_H
