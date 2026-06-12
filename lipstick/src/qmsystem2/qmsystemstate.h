/*!
 * @file qmsystemstate.h
 * @brief Contains QmSystemState which provides information and actions on device state.

   <p>
   @copyright (C) 2009-2011 Nokia Corporation
   @license LGPL Lesser General Public License

   @author Antonio Aloisio <antonio.aloisio@nokia.com>
   @author Ilya Dogolazky <ilya.dogolazky@nokia.com>
   @author Raimo Vuonnala <raimo.vuonnala@nokia.com>
   @author Timo Olkkonen <ext-timo.p.olkkonen@nokia.com>
   @author Timo Rongas <ext-timo.rongas.nokia.com>
   @author Tuomo Tanskanen <ext-tuomo.1.tanskanen@nokia.com>
   @author Simo Piiroinen <simo.piiroinen@nokia.com>
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
#ifndef QMSYSTEMSTATE_H
#define QMSYSTEMSTATE_H

#include "system_global.h"
#include <QtCore/qobject.h>

namespace MeeGo {

class QmSystemStatePrivate;

/*!
 * @scope Nokia Meego
 *
 * @class QmSystemState
 * @brief QmSystemState provides information and actions on device state.
 */
class QmSystemState : public QObject
{
    Q_OBJECT
    Q_ENUMS(StateIndication)

public:
    //! State indication
    enum StateIndication
    {
        Shutdown = 0, 		//!< Normal shutdown
        ThermalStateFatal,	//!< Shutdown due to thermal state
        BatteryStateEmpty,	//!< Shutdown due battery empty within few seconds
        SaveData,           //!< Save data
        RebootDeniedUSB,    //!< Reboot denied because USB is connected in mass storage mode
        ShutdownDeniedUSB,  //!< Shutdown denied because USB is connected in mass storage mode
        Reboot              //!< Reboot
    };

public:
    /*!
     * @brief Constructor
     * @param parent The possible parent object
     */
    QmSystemState(QObject *parent = 0);
    ~QmSystemState();

Q_SIGNALS:
    /*!
     * @brief Sent when device state indication has been received.
     * @param what Received state indication type
     */
    void systemStateChanged(MeeGo::QmSystemState::StateIndication what);

protected:
    void connectNotify(const QMetaMethod &signal);
    void disconnectNotify(const QMetaMethod &signal);

private:
    Q_DISABLE_COPY(QmSystemState)
    MEEGO_DECLARE_PRIVATE(QmSystemState)
};

} // MeeGo namespace

#endif // QMSYSTEMSTATE_H

// End of file

