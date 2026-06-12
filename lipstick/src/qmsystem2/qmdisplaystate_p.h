/*!
 * @file qmdisplaystate_p.h
 * @brief Contains QmDisplayStatePrivate

   <p>
   Copyright (C) 2009-2011 Nokia Corporation

   @author Timo Olkkonen <ext-timo.p.olkkonen@nokia.com>

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
#ifndef QMDISPLAYSTATE_P_H
#define QMDISPLAYSTATE_P_H

#include "qmdisplaystate.h"

#include <QMutex>

#include "mce/dbus-names.h"
#include "mce/mode-names.h"

#define SIGNAL_DISPLAY_STATE 0

namespace MeeGo
{
    class QmDisplayStatePrivate : public QObject
    {
        Q_OBJECT;
        MEEGO_DECLARE_PUBLIC(QmDisplayState)

    public:
        QmDisplayStatePrivate() {
            connectCount[SIGNAL_DISPLAY_STATE] = 0;
        }

        ~QmDisplayStatePrivate() {
        }

        QMutex connectMutex;
        size_t connectCount[1];

    Q_SIGNALS:
        void displayStateChanged(MeeGo::QmDisplayState::DisplayState);

    private Q_SLOTS:

        void slotDisplayStateChanged(const QString& state) {
            if (state == MCE_DISPLAY_OFF_STRING)
                emit displayStateChanged(QmDisplayState::Off);
            else if (state == MCE_DISPLAY_DIM_STRING)
                emit displayStateChanged(QmDisplayState::Dimmed);
            else if (state == MCE_DISPLAY_ON_STRING)
                emit displayStateChanged(QmDisplayState::On);
        }
    };
}
#endif // QMDISPLAYSTATE_P_H
