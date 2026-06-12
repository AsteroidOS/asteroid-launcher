/*!
 * @file qmdisplaystate.h
 * @brief Contains QmDisplayState which provides information and actions on device display state.

   <p>
   @copyright (C) 2009-2011 Nokia Corporation
   @license LGPL Lesser General Public License

   @author Antonio Aloisio <antonio.aloisio@nokia.com>
   @author Ilya Dogolazky <ilya.dogolazky@nokia.com>
   @author Raimo Vuonnala <raimo.vuonnala@nokia.com>
   @author Timo Olkkonen <ext-timo.p.olkkonen@nokia.com>
   @author Timo Rongas <ext-timo.rongas.nokia.com>
   @author Ustun Ergenoglu <ext-ustun.ergenoglu@nokia.com>

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
#ifndef QMDISPLAYSTATE_H
#define QMDISPLAYSTATE_H
#include "system_global.h"
#include <QtCore/qobject.h>

namespace MeeGo {

class QmDisplayStatePrivate;

/*!
 * @scope Nokia Meego
 *
 * @class QmDisplayState
 * @brief QmDisplayState Provides information and actions on device display state.
 */
class QmDisplayState : public QObject
{
    Q_OBJECT
    Q_ENUMS(DisplayState)
    Q_PROPERTY(DisplayState state READ get WRITE set)

public:
    //! Possible states for device display
    enum DisplayState
    {
        Off = -1,   //!< Display is off
        Dimmed = 0, //!< Display is dimmed
        On = 1,      //!< Display is on
        Unknown      //!< Display state is unknown
    };

public:
    /*!
     * Constructor
     * @param parent The parent object
     */
    QmDisplayState(QObject *parent = 0);
    ~QmDisplayState();

    /*!
     * @brief Gets the current display state
     * @return Current display state
     */
    DisplayState get() const;

    /*!
     * @brief Sets the current display state.
     * @param state Display state new set
     * @return True if a valid display state was requested, false otherwise
     */
    bool set(DisplayState state);

Q_SIGNALS:
    /*!
     * @brief Sent when display state has changed.
     * @param state Current display state
     */
    void displayStateChanged(MeeGo::QmDisplayState::DisplayState state);

protected:
    void connectNotify(const QMetaMethod &signal);
    void disconnectNotify(const QMetaMethod &signal);

private:
    Q_DISABLE_COPY(QmDisplayState)
    MEEGO_DECLARE_PRIVATE(QmDisplayState)
};

} //MeeGo namespace

#endif /* QMDISPLAYSTATE_H */

// End of file
