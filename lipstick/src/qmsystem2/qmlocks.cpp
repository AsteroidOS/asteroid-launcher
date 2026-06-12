/*!
 * @file qmlocks.cpp
 * @brief QmLocks

   <p>
   Copyright (C) 2009-2011 Nokia Corporation

   @author Antonio Aloisio <antonio.aloisio@nokia.com>
   @author Ilya Dogolazky <ilya.dogolazky@nokia.com>
   @author Timo Olkkonen <ext-timo.p.olkkonen@nokia.com>
   @author Tuomo Tanskanen <ext-tuomo.1.tanskanen@nokia.com>
   @author Matias Muhonen <ext-matias.muhonen@nokia.com>

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
#include "qmlocks.h"
#include "qmlocks_p.h"
#include <QMetaMethod>

namespace MeeGo {

QmLocks::QmLocks(QObject *parent)
             : QObject(parent) {
    MEEGO_INITIALIZE(QmLocks);

    connect(priv, SIGNAL(stateChanged(MeeGo::QmLocks::Lock, MeeGo::QmLocks::State)),
            this, SIGNAL(stateChanged(MeeGo::QmLocks::Lock,MeeGo::QmLocks::State)));
}

QmLocks::~QmLocks() {
    MEEGO_PRIVATE(QmLocks)

    disconnect(priv, SIGNAL(stateChanged(MeeGo::QmLocks::Lock, MeeGo::QmLocks::State)),
               this, SIGNAL(stateChanged(MeeGo::QmLocks::Lock,MeeGo::QmLocks::State)));

    MEEGO_UNINITIALIZE(QmLocks);
}

void QmLocks::connectNotify(const QMetaMethod &signal) {
    MEEGO_PRIVATE(QmLocks)

    /* QObject::connect() needs to be thread-safe */
    QMutexLocker locker(&priv->connectMutex);

    if (signal == QMetaMethod::fromSignal(&QmLocks::stateChanged)) {
        if (0 == priv->connectCount[SIGNAL_LOCK_STATE]) {
            QDBusConnection::systemBus().connect(MCE_SERVICE,
                                                 MCE_SIGNAL_PATH,
                                                 MCE_SIGNAL_IF,
                                                 MCE_TKLOCK_MODE_SIG,
                                                 priv,
                                                 SLOT(touchAndKeyboardStateChanged(const QString&)));
            QDBusConnection::systemBus().connect(DEVLOCK_SERVICE,
                                                 DEVLOCK_PATH,
                                                 DEVLOCK_INTERFACE,
                                                 DEVLOCK_SIGNAL,
                                                 priv,
                                                 SLOT(deviceStateChanged(int)));
        }
        priv->connectCount[SIGNAL_LOCK_STATE]++;
    }
}

void QmLocks::disconnectNotify(const QMetaMethod &signal) {
    MEEGO_PRIVATE(QmLocks)

    /* QObject::disconnect() needs to be thread-safe */
    QMutexLocker locker(&priv->connectMutex);

    if (signal == QMetaMethod::fromSignal(&QmLocks::stateChanged)) {
        priv->connectCount[SIGNAL_LOCK_STATE]--;

        if (0 == priv->connectCount[SIGNAL_LOCK_STATE]) {
            QDBusConnection::systemBus().disconnect(MCE_SERVICE,
                                                    MCE_SIGNAL_PATH,
                                                    MCE_SIGNAL_IF,
                                                    MCE_TKLOCK_MODE_SIG,
                                                    priv,
                                                    SLOT(touchAndKeyboardStateChanged(const QString&)));
            QDBusConnection::sessionBus().disconnect(DEVLOCK_SERVICE,
                                                    DEVLOCK_PATH,
                                                    DEVLOCK_SERVICE,
                                                    DEVLOCK_SIGNAL,
                                                    priv,
                                                    SLOT(deviceStateChanged(int)));
        }
    }
}

QmLocks::State QmLocks::getState(QmLocks::Lock what) const {

    return reinterpret_cast<QmLocksPrivate*>(priv_ptr)->getState(what);
}

bool QmLocks::setState(QmLocks::Lock what, QmLocks::State how) {
    MEEGO_PRIVATE(QmLocks)
    return priv->setState(what, how);
}

} // namspace MeeGo
