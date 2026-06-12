/*!
* @file qmactivity_p.h
* @brief Contains QmActivityPrivate

   <p>
   Copyright (C) 2009-2011 Nokia Corporation

   @author Timo Olkkonen <ext-timo.p.olkkonen@nokia.com>
   @author Raimo Vuonnala <raimo.vuonnala@nokia.com>
   @author Timo Rongas <ext-timo.rongas.nokia.com>
   @author Antonio Aloisio <antonio.aloisio@nokia.com>

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
#ifndef QMACTIVITY_P_H
#define QMACTIVITY_P_H

#include "qmactivity.h"

#include <QMutex>

#include "mce/dbus-names.h"
#include "mce/mode-names.h"

#define SIGNAL_INACTIVITY 0

namespace MeeGo
{
    class QmActivityPrivate : public QObject
    {
        Q_OBJECT
        MEEGO_DECLARE_PUBLIC(QmActivity)

    public:
        QMutex connectMutex;
        size_t connectCount[1];

        QmActivityPrivate() {
            connectCount[SIGNAL_INACTIVITY] = 0;
        }

        ~QmActivityPrivate() {
        }

    Q_SIGNALS:
        void activityChanged(MeeGo::QmActivity::Activity);

    public Q_SLOTS:

        void slotActivityChanged(bool inactivity) {
            if (inactivity) {
                emit activityChanged(QmActivity::Inactive);
            } else {
                emit activityChanged(QmActivity::Active);
            }
        }
    };
}

#endif // QMACTIVITY_P_H
