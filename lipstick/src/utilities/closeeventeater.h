/***************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** Copyright (C) 2012 Jolla Ltd.
** Contact: Robin Burchell <robin.burchell@jollamobile.com>
**
** This file is part of lipstick.
**
** This library is free software; you can redistribute it and/or
** modify it under the terms of the GNU Lesser General Public
** License version 2.1 as published by the Free Software Foundation
** and appearing in the file LICENSE.LGPL included in the packaging
** of this file.
**
****************************************************************************/

#ifndef CLOSEEVENTEATER_H_
#define CLOSEEVENTEATER_H_

#include <QObject>
#include "lipstickglobal.h"

/*!
 * Close event eater is an object that "eats" QCloseEvents by accepting them.
 * It can be installed to windows so that they will not react to CTRL-Q
 * presses.
 */
class LIPSTICK_EXPORT CloseEventEater : public QObject
{
    Q_OBJECT

public:
    /*!
     * Creates a close event eater.
     *
     * \param parent the parent object
     */
    CloseEventEater(QObject *parent = NULL);

protected:
    //! \reimp
    bool eventFilter(QObject *obj, QEvent *event);
    //! \reimp_end

#ifdef UNIT_TEST
    friend class Ut_CloseEventEater;
#endif
};

#endif /* CLOSEEVENTEATER_H_ */
