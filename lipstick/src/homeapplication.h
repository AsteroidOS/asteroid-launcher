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

#ifndef HOMEAPPLICATION_H_
#define HOMEAPPLICATION_H_

#include <signal.h>
#include <QGuiApplication>

class QQmlEngine;
class ScreenLock;
class VolumeControl;
class USBModeSelector;
class ShutdownScreen;
class NotificationPreviewPresenter;
class ScreenshotService;
class BluetoothAgent;
class LocaleManager;

/*!
 * Extends QApplication with features necessary to create a desktop.
 */
class HomeApplication : public QGuiApplication
{
    Q_OBJECT

    QString _compositorPath;

public:
    /*!
     * Constructs an application object.
     *
     * \param argc number of arguments passed to the application from the command line
     * \param argv argument strings passed to the application from the command line
     */
    HomeApplication(int &argc, char **argv);

    /*!
     * Destroys the application object.
     */
    virtual ~HomeApplication();

    static HomeApplication *instance();

    /*!
     * Gets the QQmlEngine used for all the windows in this application.
     */
    QQmlEngine *engine() const;

    /*!
     * Gets the path to the compositor to load.
     */
    const QString &compositorPath() const;
    /*!
     * Sets the path to the compositor QML file to run. This loads the whole
     * UI (the home screen lives inside the compositor scene), so it must be
     * called after the context properties and QML types the scene needs.
     */
    void setCompositorPath(const QString &path);

    /*!
     * Restores any installed signal handlers.
     */
    void restoreSignalHandlers();

    /*!
     * Gets the home active flag.
     */
    bool homeActive() const;

    void takeScreenshot(const QString &path);

signals:
    /*!
     * Emitted whenever the home active flag changes.
     */
    void homeActiveChanged();

    /*!
     * Emitted when the home screen has been drawn on screen for the first time.
     */
    void homeReady();

    /*
     * Emitted before the HomeApplication commences destruction.
     */
    void aboutToDestroy();

protected:
    virtual bool event(QEvent *);

private slots:
    /*!
     * Emits the homeReady() signal unless it has already been sent
     */
    void sendHomeReadySignalIfNotAlreadySent();

    /*!
     * Sends a dbus-signal after UI is visible, stops the process if it has
     * been started by upstart
     */
    void sendStartupNotifications();

private:
    friend class LipstickApi;

    //! A signal handler that quits the QApplication
    static void quitSignalHandler(int);

    //! The original SIGINT handler
    sighandler_t originalSigIntHandler;

    //! The original SIGTERM handler
    sighandler_t originalSigTermHandler;

    //! QML Engine instance
    QQmlEngine *qmlEngine;

    //! Logic for locking and unlocking the screen
    ScreenLock *screenLock;

    //! Logic for setting the device volume
    VolumeControl *volumeControl;

    //! Logic for showing the USB mode selection dialog
    USBModeSelector *usbModeSelector;

    //! Logic for showing the Bluetooth pairing dialog
    BluetoothAgent *bluetoothAgent;

    //! Logic for showing the Bluetooth pairing dialog
    LocaleManager *localeMngr;

    //! Logic for showing the shutdown screen and related notifications
    ShutdownScreen *shutdownScreen;

    //! Tracks which notification should currently be previewed
    NotificationPreviewPresenter *notificationPreviewPresenter;

    //! Whether the home ready signal has been sent or not
    bool homeReadySent;

    ScreenshotService *m_screenshotService;
};

#endif /* HOMEAPPLICATION_H_ */
