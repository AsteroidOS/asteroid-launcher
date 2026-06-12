/***************************************************************************
**
** Copyright (C) 2017 Florent Revest <revestflo@gmail.com>
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

#ifndef LOCALEMANAGER_H
#define LOCALEMANAGER_H

#include <QObject>
#include <QTranslator>
#include <QDBusAbstractAdaptor>

#include <homeapplication.h>

class LocaleManager : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.nemomobile.lipstick")
    Q_PROPERTY(QString changesObserver READ getEmptyString NOTIFY emptyStringChanged)

public:
    LocaleManager(HomeApplication *app);
    QString getEmptyString();

public slots:
    Q_INVOKABLE void selectLocale(QString locale);

signals:
    void localeChanged();
    void emptyStringChanged();

private:
    HomeApplication *m_app;
    QTranslator *m_translator;
};

#endif // LOCALEMANAGER_H

