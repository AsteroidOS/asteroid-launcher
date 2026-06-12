/*!
 * @file qmlocks.h
 * @brief Contains QmLocks which allows to get and set the state of the touchscreen/keypad lock.

   <p>
   @copyright (C) 2009-2011 Nokia Corporation
   @license LGPL Lesser General Public License

   @author Antonio Aloisio <antonio.aloisio@nokia.com>
   @author Ilya Dogolazky <ilya.dogolazky@nokia.com>
   @author Raimo Vuonnala <raimo.vuonnala@nokia.com>
   @author Timo Olkkonen <ext-timo.p.olkkonen@nokia.com>
   @author Timo Rongas <ext-timo.rongas@nokia.com>
   @author Matias Muhonen <ext-matias.muhonen@nokia.com>

   @scope Nokia Meego

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
#ifndef QMLOCKS_H
#define QMLOCKS_H
#include "system_global.h"
#include <QtCore/qobject.h>

namespace MeeGo {

class QmLocksPrivate;

/**
 * @scope Nokia Meego
 *
 * @brief Provides information and actions on device locks.
 */
class QmLocks : public QObject
{
    Q_OBJECT
    Q_ENUMS(Lock)
    Q_ENUMS(State)

public:
    /** Things that can be locked. */
    enum Lock
    {
        /**
         * Device lock.
         * @deprecated The device lock functionality is deprecated. Please use the devicelock interface.
         */
        Device = 0,
        /**
         * Touchscreen/keypad lock
         */
        TouchAndKeyboard
    };

    /** Lock states */
    enum State
    {
        /**
         * Unlocked
         */
        Unlocked = 0,
        /**
         * Locked
         */
        Locked,
        /**
         * Unknown
         */
        Unknown
    };

public:
    QmLocks(QObject *parent = 0);
    ~QmLocks();

    /**
     * Gets the current lock state. Note: the method blocks until
     * the lock state has been retrieved.
     *
     * @param what Which lock state to request
     * @return Current lock state for @c what
     */
    QmLocks::State getState(QmLocks::Lock what) const;

    /**
     * Sets the current lock state. Note that this interface does not allow
     * to unlock device.
     * @credential mce::TKLockControl Resource token required to set the touchscreen/keypad lock state.
     * @param what Which lock state to set
     * @param how Set @c to which state
     * @return True if the lock state was requested, false otherwise
     */
    bool setState(QmLocks::Lock what, QmLocks::State how);

Q_SIGNALS:
    /**
     * Sent when some device lock state has changed.
     * @param what Which lock state was changed
     * @param how Which state the lock was changed to
     */
    void stateChanged(MeeGo::QmLocks::Lock what, MeeGo::QmLocks::State how);

protected:
    void connectNotify(const QMetaMethod &signal);
    void disconnectNotify(const QMetaMethod &signal);

private:
    Q_DISABLE_COPY(QmLocks)
    MEEGO_DECLARE_PRIVATE(QmLocks)
};

} // namspace MeeGo

#endif /* QMLOCKS_H */

// End of file
