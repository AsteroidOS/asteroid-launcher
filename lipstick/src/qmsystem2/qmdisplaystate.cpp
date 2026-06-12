/*!
 * @file qmdisplaystate.cpp
 * @brief QmDisplayState

   <p>
   Copyright (C) 2009-2011 Nokia Corporation

   @author Antonio Aloisio <antonio.aloisio@nokia.com>
   @author Ilya Dogolazky <ilya.dogolazky@nokia.com>
   @author Timo Olkkonen <ext-timo.p.olkkonen@nokia.com>
   @author Ustun Ergenoglu <ext-ustun.ergenoglu@nokia.com>
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
#include "qmdisplaystate.h"
#include "qmdisplaystate_p.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusReply>
#include <QMetaMethod>

namespace MeeGo {

QmDisplayState::QmDisplayState(QObject *parent)
              : QObject(parent) {
     MEEGO_INITIALIZE(QmDisplayState);

     connect(priv, SIGNAL(displayStateChanged(MeeGo::QmDisplayState::DisplayState)),
             this, SIGNAL(displayStateChanged(MeeGo::QmDisplayState::DisplayState)));
}

QmDisplayState::~QmDisplayState() {
    MEEGO_PRIVATE(QmDisplayState)

    disconnect(priv, SIGNAL(displayStateChanged(MeeGo::QmDisplayState::DisplayState)),
               this, SIGNAL(displayStateChanged(MeeGo::QmDisplayState::DisplayState)));

    MEEGO_UNINITIALIZE(QmDisplayState);
}

void QmDisplayState::connectNotify(const QMetaMethod &signal) {
    MEEGO_PRIVATE(QmDisplayState)

    /* QObject::connect() needs to be thread-safe */
    QMutexLocker locker(&priv->connectMutex);

    if (signal == QMetaMethod::fromSignal(&QmDisplayState::displayStateChanged)) {
        if (0 == priv->connectCount[SIGNAL_DISPLAY_STATE]) {
            QDBusConnection::systemBus().connect(MCE_SERVICE,
                                                 MCE_SIGNAL_PATH,
                                                 MCE_SIGNAL_IF,
                                                 MCE_DISPLAY_SIG,
                                                 priv,
                                                 SLOT(slotDisplayStateChanged(const QString&)));
        }
        priv->connectCount[SIGNAL_DISPLAY_STATE]++;
    }
}

void QmDisplayState::disconnectNotify(const QMetaMethod &signal) {
    MEEGO_PRIVATE(QmDisplayState)

    /* QObject::disconnect() needs to be thread-safe */
    QMutexLocker locker(&priv->connectMutex);

    if (signal == QMetaMethod::fromSignal(&QmDisplayState::displayStateChanged)) {
        priv->connectCount[SIGNAL_DISPLAY_STATE]--;

        if (0 == priv->connectCount[SIGNAL_DISPLAY_STATE]) {
            QDBusConnection::systemBus().disconnect(MCE_SERVICE,
                                                    MCE_SIGNAL_PATH,
                                                    MCE_SIGNAL_IF,
                                                    MCE_DISPLAY_SIG,
                                                    priv,
                                                    SLOT(slotDisplayStateChanged(const QString&)));
        }
    }
}

QmDisplayState::DisplayState QmDisplayState::get() const {
    QmDisplayState::DisplayState state = Unknown;
    QDBusReply<QString> displayStateReply = QDBusConnection::systemBus().call(
                                                QDBusMessage::createMethodCall(MCE_SERVICE, MCE_REQUEST_PATH, MCE_REQUEST_IF,
                                                                               MCE_DISPLAY_STATUS_GET));
    if (!displayStateReply.isValid()) {
        return state;
    }

    QString stateStr = displayStateReply.value();

    if (stateStr == MCE_DISPLAY_DIM_STRING) {
        state = Dimmed;
    } else if (stateStr == MCE_DISPLAY_ON_STRING) {
        state = On;
    } else if (stateStr == MCE_DISPLAY_OFF_STRING) {
        state = Off;
    }
    return state;
}

bool QmDisplayState::set(QmDisplayState::DisplayState state) {
    QString method;

    switch (state) {
        case Off:
            method = QString(MCE_DISPLAY_OFF_REQ);
            break;
        case Dimmed:
            method = QString(MCE_DISPLAY_DIM_REQ);
            break;
        case On:
            method = QString(MCE_DISPLAY_ON_REQ);
            break;
        default:
            return false;
    }

    QDBusMessage displayStateSetCall = QDBusMessage::createMethodCall(MCE_SERVICE, MCE_REQUEST_PATH, MCE_REQUEST_IF, method);
    (void)QDBusConnection::systemBus().call(displayStateSetCall, QDBus::NoBlock);
    return true;
}

} //MeeGo namespace
