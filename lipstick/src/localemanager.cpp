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

#include "localemanager.h"

#include <QLocale>
#include <QDBusConnection>

LocaleManager::LocaleManager(HomeApplication *app) : QDBusAbstractAdaptor(app)
{
    m_app = app;
    m_translator = new QTranslator(this);
    m_translator->load(QLocale(), "lipstick", "-", "/usr/share/translations");
    m_app->installTranslator(m_translator);

    QDBusConnection::systemBus().registerObject("/org/nemomobile/lipstick/localemanager", this, QDBusConnection::ExportAllSlots);
}

QString LocaleManager::getEmptyString()
{
    return "";
}

void LocaleManager::selectLocale(QString locale)
{
    QLocale::setDefault(QLocale(locale));
    qputenv("LANG", locale.toUtf8());

    m_app->removeTranslator(m_translator);
    m_translator->load(QLocale(), "lipstick", "-", "/usr/share/translations");
    m_app->installTranslator(m_translator);

    emit localeChanged();
    emit emptyStringChanged();
}

