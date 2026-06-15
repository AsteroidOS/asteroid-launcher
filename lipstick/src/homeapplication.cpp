/***************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
**
** This library is free software; you can redistribute it and/or
** modify it under the terms of the GNU Lesser General Public
** License version 2.1 as published by the Free Software Foundation
** and appearing in the file LICENSE.LGPL included in the packaging
** of this file.
**
****************************************************************************/

#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QScreen>
#include <QTimer>
#include <QDBusMessage>
#include <QDBusConnection>
#include <QIcon>
#include <QTranslator>
#include <QDebug>
#include <QEvent>
#include <systemd/sd-daemon.h>

#include "notifications/notificationmanager.h"
#include "notifications/notificationpreviewpresenter.h"
#include "notifications/batterynotifier.h"
#include "notifications/diskspacenotifier.h"
#include "notifications/thermalnotifier.h"
#include "screenlock/screenlock.h"
#include "screenlock/screenlockadaptor.h"
#include "lipsticksettings.h"
#include "homeapplication.h"
#include "compositor/lipstickcompositor.h"
#include "compositor/lipstickcompositorwindow.h"
#include "lipstickdbus.h"

#include "volume/volumecontrol.h"
#include "usbmodeselector.h"
#include "bluetoothagent.h"
#include "localemanager.h"
#include "shutdownscreen.h"
#include "screenshotservice.h"
#include "screenshotserviceadaptor.h"

void HomeApplication::quitSignalHandler(int)
{
    qApp->quit();
}

static void registerDBusObject(QDBusConnection &bus, const char *path, QObject *object)
{
    if (!bus.registerObject(path, object)) {
        qWarning("Unable to register object at path %s: %s", path, bus.lastError().message().toUtf8().constData());
    }
}

HomeApplication::HomeApplication(int &argc, char **argv)
    : QGuiApplication(argc, argv)
    , originalSigIntHandler(signal(SIGINT, quitSignalHandler))
    , originalSigTermHandler(signal(SIGTERM, quitSignalHandler))
    , homeReadySent(false)
{
    // Set the application name, as used in notifications
    //% "System"
    setApplicationName(qtTrId("qtn_ap_lipstick"));
    setApplicationVersion(VERSION);

    // Initialize the QML engine
    qmlEngine = new QQmlEngine(this);

    // Initialize the notification manager
    NotificationManager::instance();
    notificationPreviewPresenter = new NotificationPreviewPresenter(this);

    // Export screen size / geometry as dconf keys
    LipstickSettings::instance()->exportScreenSize();

    // Create screen lock logic - not parented to "this" since destruction happens too late in that case
    screenLock = new ScreenLock;
    LipstickSettings::instance()->setScreenLock(screenLock);
    new ScreenLockAdaptor(screenLock);

    volumeControl = new VolumeControl;
    new BatteryNotifier(this);
    new DiskSpaceNotifier(this);
    new ThermalNotifier(this);
    usbModeSelector = new USBModeSelector(this);
    bluetoothAgent = new BluetoothAgent(this);
    shutdownScreen = new ShutdownScreen(this);
    localeMngr = new LocaleManager(this);

    // MCE and usb-moded expect services to be registered on the system bus
    QDBusConnection systemBus = QDBusConnection::systemBus();
    if (!systemBus.registerService(LIPSTICK_DBUS_SERVICE_NAME)) {
        qWarning("Unable to register D-Bus service %s: %s", LIPSTICK_DBUS_SERVICE_NAME, systemBus.lastError().message().toUtf8().constData());
    }

    registerDBusObject(systemBus, LIPSTICK_DBUS_SCREENLOCK_PATH, screenLock);

    m_screenshotService = new ScreenshotService(this);
    new ScreenshotServiceAdaptor(m_screenshotService);

    registerDBusObject(systemBus, LIPSTICK_DBUS_SCREENSHOT_PATH, m_screenshotService);

    // Setting up the context and engine things
    qmlEngine->rootContext()->setContextProperty("initialSize", QGuiApplication::primaryScreen()->size());
    qmlEngine->rootContext()->setContextProperty("lipstickSettings", LipstickSettings::instance());
    qmlEngine->rootContext()->setContextProperty("volumeControl", volumeControl);
    qmlEngine->rootContext()->setContextProperty("localeManager", localeMngr);
    // Overlays rendered directly in the compositor scene (compositor.qml)
    qmlEngine->rootContext()->setContextProperty("notificationPreviewPresenter", notificationPreviewPresenter);
    qmlEngine->rootContext()->setContextProperty("shutdownScreen", shutdownScreen);
    qmlEngine->rootContext()->setContextProperty("bluetoothAgent", bluetoothAgent);

    connect(this, SIGNAL(homeReady()), this, SLOT(sendStartupNotifications()));
}

HomeApplication::~HomeApplication()
{
    emit aboutToDestroy();

    delete volumeControl;
    delete screenLock;
    delete qmlEngine;
}

HomeApplication *HomeApplication::instance()
{
    return qobject_cast<HomeApplication *>(qApp);
}

void HomeApplication::restoreSignalHandlers()
{
    signal(SIGINT, originalSigIntHandler);
    signal(SIGTERM, originalSigTermHandler);
}

void HomeApplication::sendHomeReadySignalIfNotAlreadySent()
{
    if (!homeReadySent) {
        homeReadySent = true;
        disconnect(LipstickCompositor::instance()->quickWindow(), SIGNAL(frameSwapped()), this, SLOT(sendHomeReadySignalIfNotAlreadySent()));

        emit homeReady();
    }
}

void HomeApplication::sendStartupNotifications()
{
    static QDBusConnection systemBus = QDBusConnection::systemBus();
    QDBusMessage homeReadySignal =
        QDBusMessage::createSignal("/com/nokia/duihome",
                                   "com.nokia.duihome.readyNotifier",
                                   "ready");
    systemBus.send(homeReadySignal);

    /* Let systemd know that we are initialized */
    if (arguments().indexOf("--systemd") >= 0) {
        sd_notify(0, "READY=1");
    }

    /* Let timed know that the UI is up */
    systemBus.call(QDBusMessage::createSignal("/com/nokia/startup/signal", "com.nokia.startup.signal", "desktop_visible"), QDBus::NoBlock);
}

bool HomeApplication::homeActive() const
{
    LipstickCompositor *c = LipstickCompositor::instance();
    return c?c->homeActive():(QGuiApplication::focusWindow() != 0);
}

bool HomeApplication::event(QEvent *e)
{
    bool rv = QGuiApplication::event(e);
    if (LipstickCompositor::instance() == 0 &&
        (e->type() == QEvent::ApplicationActivate ||
         e->type() == QEvent::ApplicationDeactivate))
        emit homeActiveChanged();
    return rv;
}

const QString &HomeApplication::compositorPath() const
{
    return _compositorPath;
}

void HomeApplication::setCompositorPath(const QString &path)
{
    if (path.isEmpty()) {
        qWarning() << "HomeApplication: Invalid empty compositor path";
        return;
    }

    if (!_compositorPath.isEmpty()) {
        qWarning() << "HomeApplication: Compositor already set";
        return;
    }

    _compositorPath = path;
    QQmlComponent component(qmlEngine, QUrl(path));
    if (component.isError()) {
        qWarning() << "HomeApplication: Errors while loading compositor from" << path;
        qWarning() << component.errors();
        return;
    } 

    QQuickItem *compositor = qobject_cast<QQuickItem*>(component.beginCreate(qmlEngine->rootContext()));
    if (compositor) {
        compositor->setParent(this);

        if (LipstickCompositor::instance()) {
            LipstickCompositor::instance()->quickWindow()->setGeometry(QRect(QPoint(0, 0), QGuiApplication::primaryScreen()->size()));
            compositor->setParentItem(LipstickCompositor::instance()->quickWindow()->contentItem());
        }

        component.completeCreate();

        if (!qmlEngine->incubationController() && LipstickCompositor::instance()) {
            // install default incubation controller
            qmlEngine->setIncubationController(LipstickCompositor::instance()->quickWindow()->incubationController());
        }

        // The home screen is part of the compositor scene now; emit homeReady
        // once that scene has rendered its first frame.
        connect(LipstickCompositor::instance()->quickWindow(), SIGNAL(frameSwapped()),
                this, SLOT(sendHomeReadySignalIfNotAlreadySent()));
    } else {
        qWarning() << "HomeApplication: Error creating compositor from" << path;
        qWarning() << component.errors();
    }
}

QQmlEngine *HomeApplication::engine() const
{
    return qmlEngine;
}

void HomeApplication::takeScreenshot(const QString &path)
{
    m_screenshotService->saveScreenshot(path);
}
