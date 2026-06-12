// This file is part of lipstick, a QML desktop library
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
//
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>

#include "lipstickqmltypes.h"

#include <QtQml>
#include <QQmlParserStatus>
#include <QQuickWindow>
#include <QWaylandSurface>
#include <components/launchermodel.h>
#include <components/launcherfoldermodel.h>
#include <components/launcheritem.h>
#include <components/launcherwatchermodel.h>
#include <notifications/notificationpreviewpresenter.h>
#include <notifications/notificationfeedbackplayer.h>
#include <notifications/notificationlistmodel.h>
#include <notifications/lipsticknotification.h>
#include <volume/volumecontrol.h>
#include <usbmodeselector.h>
#include <shutdownscreen.h>
#include <bluetoothagent.h>
#include <compositor/lipstickcompositor.h>
#include <compositor/lipstickcompositorwindow.h>
#include <compositor/windowmodel.h>
#include <compositor/windowpixmapitem.h>
#include <lipstickapi.h>

class LauncherModelType : public LauncherModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
public:
    explicit LauncherModelType(QObject *parent = 0)
        : LauncherModel(DeferInitialization, parent)
    {
    }

    void classBegin() {}
    void componentComplete() { initialize(); }
};

class LauncherFolderModelType : public LauncherFolderModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
public:
    explicit LauncherFolderModelType(QObject *parent = 0)
        : LauncherFolderModel(DeferInitialization, parent)
    {
    }

    void classBegin() {}
    void componentComplete() { initialize(); }
};

static QObject *lipstickApi_callback(QQmlEngine *e, QJSEngine *)
{
    return new LipstickApi(e);
}

void registerLipstickTypes()
{
    qmlRegisterType<LauncherModelType>("org.nemomobile.lipstick", 0, 1, "LauncherModel");
    qmlRegisterType<LauncherWatcherModel>("org.nemomobile.lipstick", 0, 1, "LauncherWatcherModel");
    qmlRegisterType<NotificationListModel>("org.nemomobile.lipstick", 0, 1, "NotificationListModel");
    qmlRegisterType<LipstickNotification>("org.nemomobile.lipstick", 0, 1, "Notification");
    qmlRegisterType<LauncherItem>("org.nemomobile.lipstick", 0, 1, "LauncherItem");
    qmlRegisterType<LauncherFolderModelType>("org.nemomobile.lipstick", 0, 1, "LauncherFolderModel");
    qmlRegisterType<LauncherFolderItem>("org.nemomobile.lipstick", 0, 1, "LauncherFolderItem");

    qmlRegisterUncreatableType<NotificationPreviewPresenter>("org.nemomobile.lipstick", 0, 1, "NotificationPreviewPresenter", "This type is initialized by HomeApplication");
    qmlRegisterUncreatableType<NotificationFeedbackPlayer>("org.nemomobile.lipstick", 0, 1, "NotificationFeedbackPlayer", "This type is initialized by HomeApplication");
    qmlRegisterUncreatableType<VolumeControl>("org.nemomobile.lipstick", 0, 1, "VolumeControl", "This type is initialized by HomeApplication");
    qmlRegisterUncreatableType<USBModeSelector>("org.nemomobile.lipstick", 0, 1, "USBModeSelector", "This type is initialized by HomeApplication");
    qmlRegisterUncreatableType<ShutdownScreen>("org.nemomobile.lipstick", 0, 1, "ShutdownScreen", "This type is initialized by HomeApplication");

    qmlRegisterType<LipstickCompositor>("org.nemomobile.lipstick", 0, 1, "Compositor");
    qmlRegisterUncreatableType<QWaylandSurface>("org.nemomobile.lipstick", 0, 1, "WaylandSurface", "This type is created by the compositor");
    qmlRegisterType<WindowModel>("org.nemomobile.lipstick", 0, 1, "WindowModel");
    qmlRegisterType<WindowPixmapItem>("org.nemomobile.lipstick", 0, 1, "WindowPixmapItem");
    qmlRegisterSingletonType<LipstickApi>("org.nemomobile.lipstick", 0, 1, "Lipstick", lipstickApi_callback);

    qmlRegisterRevision<QQuickWindow,1>("org.nemomobile.lipstick", 0, 1);

    qmlRegisterUncreatableType<BluetoothAgent>("org.nemomobile.lipstick", 0, 1, "BluetoothAgent", "This type is created by lipstick");
}

#include "lipstickqmltypes.moc"
