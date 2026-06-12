
// This file is part of lipstick, a QML desktop library
//
// Copyright (c) 2014 Jolla Ltd.
// Contact: Thomas Perl <thomas.perl@jolla.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License version 2.1 as published by the Free Software Foundation
// and appearing in the file LICENSE.LGPL included in the packaging
// of this file.
//
// This code is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.

#include "launcherdbus.h"

#include "launcheritem.h"
#include "launchermodel.h"

#include <QDBusConnection>
#include <QDBusMessage>


LauncherDBus::LauncherDBus(LauncherModel *model)
    : QObject(model)
    , QDBusContext()
{
    QDBusConnection dbus = QDBusConnection::sessionBus();
    dbus.registerObject(LIPSTICK_DBUS_LAUNCHER_MODEL_PATH,
            this, QDBusConnection::ExportAllSlots |
            QDBusConnection::ExportAllSignals);

    if (model) {
        m_models.append(model);
    }
}

LauncherDBus::~LauncherDBus()
{
}

void LauncherDBus::registerModel(LauncherModel *model)
{
    m_models.append(model);
}

void LauncherDBus::deregisterModel(LauncherModel *model)
{
    m_models.removeOne(model);
}

void LauncherDBus::notifyLaunching(const QString &desktopFile)
{
    foreach (LauncherModel *model, m_models) {
        model->notifyLaunching(desktopFile);
    }
}
