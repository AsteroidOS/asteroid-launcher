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
#include <QDBusInterface>
#include <QDebug>

LocaleManager::LocaleManager(HomeApplication *app) : QDBusAbstractAdaptor(app)
{
    m_app = app;

    // English fallback catalog, so that ids missing from the current locale's
    // catalog (or locales without a catalog at all) render as English text
    // instead of raw message ids. Installed first: translators are searched
    // most-recently-installed first, so the locale catalog below wins.
    m_fallbackTranslator = new QTranslator(this);
    if (m_fallbackTranslator->load("asteroid-launcher.en", "/usr/share/translations"))
        m_app->installTranslator(m_fallbackTranslator);

    m_translator = new QTranslator(this);
    loadLocaleCatalog();

    QDBusConnection::systemBus().registerObject("/org/nemomobile/lipstick/localemanager", this, QDBusConnection::ExportAllSlots);
}

void LocaleManager::loadLocaleCatalog()
{
    if (!m_translator->load(QLocale(), "asteroid-launcher", ".", "/usr/share/translations", ".qm")) {
        qDebug() << "asteroid-launcher: Failed to load" << QLocale().name() << "translations";
    }
    m_app->installTranslator(m_translator);
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
    loadLocaleCatalog();

    // Propagate the locale to apps: newly spawned processes inherit it from
    // the user session, and the booster respawns with it for prelaunching
    QDBusInterface systemdInterface("org.freedesktop.systemd1", "/org/freedesktop/systemd1", "org.freedesktop.systemd1.Manager", QDBusConnection::sessionBus());
    systemdInterface.call("SetEnvironment", QStringList() << ("LANG=" + locale));
    systemdInterface.call("RestartUnit", "booster-asteroid-qt6.service", "replace");

    emit localeChanged();
    emit emptyStringChanged();
}

