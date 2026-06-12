/***************************************************************************
**
** Copyright (C) 2015 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
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

#ifndef ANDROIDPRIORITYSTORE_H_
#define ANDROIDPRIORITYSTORE_H_

#include <QHash>
#include <QObject>
#include <QString>

class AndroidPriorityStore : public QObject
{
    Q_OBJECT

public:
    typedef QPair<int, QString> PriorityDetails;

    /*!
     * Creates an Android priority store.
     *
     * \param path The path where Android priority information is defined.
     */
    explicit AndroidPriorityStore(const QString &path, QObject *parent = 0);

    /*!
     * Returns the priority information defined for the given Android app name.
     *
     * \param appName The name of the Android app to return priority information for.
     */
    PriorityDetails appDetails(const QString &appName) const;

    /*!
     * Returns the priority information defined for the given Android package name.
     *
     * \param packageName The name of the Android package to return priority information for.
     */
    PriorityDetails packageDetails(const QString &packageName) const;

private:
    QHash<QString, QString> priorityDefinitions;
};

#endif /* ANDROIDPRIORITYSTORE_H_ */
