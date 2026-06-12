/***************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
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

#ifndef CONNECTIONSELECTOR_H
#define CONNECTIONSELECTOR_H

#include <QObject>
#include "lipstickglobal.h"

class HomeWindow;

class LIPSTICK_EXPORT ConnectionSelector : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool windowVisible READ windowVisible WRITE setWindowVisible NOTIFY windowVisibleChanged)

public:
    /*!
     * Creates a connection selector.
     *
     * \param parent the parent object
     */
    explicit ConnectionSelector(QObject *parent = 0);

    /*!
     * Destroys the connection selector.
     */
    virtual ~ConnectionSelector();

    /*!
     * Returns whether the window is visible or not.
     *
     * \return \c true if the window is visible, \c false otherwise
     */
    bool windowVisible() const;

    /*!
     * Sets the visibility of the window.
     *
     * \param visible \c true if the window should be visible, \c false otherwise
     */
    void setWindowVisible(bool visible);

private slots:
    /*!
     * Creates the window.
     */
    void createWindow();

signals:
    //! Sent when the visibility of the window has changed.
    void windowVisibleChanged();

private:
    HomeWindow *window;
};

#endif // CONNECTIONSELECTOR_H
