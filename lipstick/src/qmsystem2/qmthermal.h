/*!
 * @file qmthermal.h
 * @brief Contains QmThermal which provides information on device thermal states.

   <p>
   @copyright (C) 2009-2011 Nokia Corporation
   @license LGPL Lesser General Public License

   @author Antonio Aloisio <antonio.aloisio@nokia.com>
   @author Ilya Dogolazky <ilya.dogolazky@nokia.com>
   @author Raimo Vuonnala <raimo.vuonnala@nokia.com>
   @author Timo Olkkonen <ext-timo.p.olkkonen@nokia.com>
   @author Timo Rongas <ext-timo.rongas.nokia.com>

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
#ifndef QMTHERMAL_H
#define QMTHERMAL_H

#include "system_global.h"
#include <QtCore/qobject.h>

namespace MeeGo{

class QmThermalPrivate;

/*!
 * @scope Nokia Meego
 *
 * @class QmThermal
 * @brief QmThermal provides information on device thermal states.
 */
class QmThermal : public QObject
{
    Q_OBJECT
    Q_ENUMS(ThermalState)
    Q_PROPERTY(ThermalState state READ get)

public:
    //! Possible thermal states - the state transitions are not necessarily linear
    enum ThermalState
    {
        Normal = 0, //!< Normal
        Warning,    //!< Warning state
        Alert,      //!< Alert state
        Unknown,    //!< State not known, just ignore !
        Error,      //!< State could not be retrieved (for get method only)
        LowTemperatureWarning     //!< Low temperature warning state
    };


public:
    /*!
     * @brief Constructor
     * @param parent The possible parent object
     */
    QmThermal(QObject *parent = 0);
	
	/*!
     * @brief Destructor
     */	
    ~QmThermal();

    /*!
     * @brief Gets the current thermal state.
     * @return Current thermal state
     */
    ThermalState get() const;

Q_SIGNALS:
    /*!
     * @brief Sent when device thermal state has changed.
     * @param state Current thermal state
     */
    void thermalChanged(MeeGo::QmThermal::ThermalState state);

protected:
    void connectNotify(const QMetaMethod &signal);
    void disconnectNotify(const QMetaMethod &signal);

private:
    Q_DISABLE_COPY(QmThermal)
    MEEGO_DECLARE_PRIVATE(QmThermal)
};

} // MeeGo namespace

#endif /*QMTHERMAL_H*/

// End of file

