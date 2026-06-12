/*!
 * @file qmactivity.cpp
 * @brief QmActivity

   <p>
   Copyright (C) 2009-2011 Nokia Corporation

   @author Antonio Aloisio <antonio.aloisio@nokia.com>
   @author Ilya Dogolazky <ilya.dogolazky@nokia.com>
   @author Timo Olkkonen <ext-timo.p.olkkonen@nokia.com>
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
#include "qmactivity.h"
#include "qmactivity_p.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusReply>
#include <QMetaMethod>

namespace MeeGo {

QmActivity::QmActivity(QObject *parent)
           : QObject(parent) {
    MEEGO_INITIALIZE(QmActivity);

    connect(priv, SIGNAL(activityChanged(MeeGo::QmActivity::Activity)),
            this, SIGNAL(activityChanged(MeeGo::QmActivity::Activity)));
}

QmActivity::~QmActivity() {
    MEEGO_PRIVATE(QmActivity)

    disconnect(priv, SIGNAL(activityChanged(MeeGo::QmActivity::Activity)),
               this, SIGNAL(activityChanged(MeeGo::QmActivity::Activity)));

    MEEGO_UNINITIALIZE(QmActivity);
}

void QmActivity::connectNotify(const QMetaMethod &signal) {
    MEEGO_PRIVATE(QmActivity)

    /* QObject::connect() needs to be thread-safe */
    QMutexLocker locker(&priv->connectMutex);

    if (signal == QMetaMethod::fromSignal(&QmActivity::activityChanged)) {
        if (0 == priv->connectCount[SIGNAL_INACTIVITY]) {
            QDBusConnection::systemBus().connect(MCE_SERVICE,
                                                 MCE_SIGNAL_PATH,
                                                 MCE_SIGNAL_IF,
                                                 MCE_INACTIVITY_SIG,
                                                 priv,
                                                 SLOT(slotActivityChanged(bool)));
        }
        priv->connectCount[SIGNAL_INACTIVITY]++;
    }
}

void QmActivity::disconnectNotify(const QMetaMethod &signal) {
    MEEGO_PRIVATE(QmActivity)

    /* QObject::disconnect() needs to be thread-safe */
    QMutexLocker locker(&priv->connectMutex);

    if (signal == QMetaMethod::fromSignal(&QmActivity::activityChanged)) {
        priv->connectCount[SIGNAL_INACTIVITY]--;

        if (0 == priv->connectCount[SIGNAL_INACTIVITY]) {
            QDBusConnection::systemBus().disconnect(MCE_SERVICE,
                                                    MCE_SIGNAL_PATH,
                                                    MCE_SIGNAL_IF,
                                                    MCE_INACTIVITY_SIG,
                                                    priv,
                                                    SLOT(slotActivityChanged(bool)));
        }
    }
}

QmActivity::Activity QmActivity::get() const {
    QmActivity::Activity status = Inactive;
    QDBusReply<bool> inactivityStatusReply = QDBusConnection::systemBus().call(
                                                 QDBusMessage::createMethodCall(MCE_SERVICE, MCE_REQUEST_PATH, MCE_REQUEST_IF,
                                                                                MCE_INACTIVITY_STATUS_GET));
    if (!inactivityStatusReply.isValid()) {
        return status;
    }

    bool inactivityStatus = inactivityStatusReply.value();
    if (!inactivityStatus) {
        status = Active;
    }
    return status;
}

}
