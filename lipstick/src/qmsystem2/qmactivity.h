/*!
* @file qmactivity.h
* @brief Contains QmActivity

   <p>
   @copyright (C) 2009-2011 Nokia Corporation
   @license LGPL Lesser General Public License

   @author Timo Olkkonen <ext-timo.p.olkkonen@nokia.com>
   @author Raimo Vuonnala <raimo.vuonnala@nokia.com>
   @author Timo Rongas <ext-timo.rongas.nokia.com>
   @author Antonio Aloisio <antonio.aloisio@nokia.com>

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
#ifndef QMACTIVITY_H
#define QMACTIVITY_H
#include <QtCore/qobject.h>
#include "system_global.h"

namespace MeeGo {

class QmActivityPrivate;

/*!
 * @class QmActivity
 *
 * @scope Nokia Meego
 *
 * @brief QmActivity provides information about user activity.
 * @details QmActivity offers a getter method as well as a changed signal
 * for the user activity state. The state is fetched from the mce daemon
 */
class QmActivity : public QObject
{
    Q_OBJECT
    Q_ENUMS(Activity)
    Q_PROPERTY(Activity status READ get)

public:
    //! Possible user activity states
    enum Activity
    {
        Inactive = 0, //!< Inactive
        Active        //!< Active
    };

public:
    /*!
     * @brief Constructor
     * @param parent The possible parent object
     */
    QmActivity(QObject *parent = 0);

    /*!
     * @brief Destructor
     */
    ~QmActivity();

    /*!
     * @brief Gets the current activity state.
     * @return The current activity state
     */
    Activity get() const;

Q_SIGNALS:
    /*!
     * @brief Sent when activity state has changed.
     * @param activity The new activity state
     * @param activity The new activity state
     */
    void activityChanged(MeeGo::QmActivity::Activity activity);

protected:
    void connectNotify(const QMetaMethod &signal);
    void disconnectNotify(const QMetaMethod &signal);

private:
    Q_DISABLE_COPY(QmActivity)
    MEEGO_DECLARE_PRIVATE(QmActivity)
};

} // MeeGo namespace

#endif /*QMACTIVITY_H*/

// End of file

