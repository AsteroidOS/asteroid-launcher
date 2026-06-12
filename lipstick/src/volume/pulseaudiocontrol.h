/***************************************************************************
**
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

#ifndef PULSEAUDIOCONTROL_H
#define PULSEAUDIOCONTROL_H

#include <QObject>
#include <dbus/dbus.h>

/*!
 * \class PulseAudioControl
 *
 * \brief Gets and sets the volume using the MainVolume API.
 */
class PulseAudioControl : public QObject
{
    Q_OBJECT

public:
    //! Construct a PulseAudioControl instance
    PulseAudioControl(QObject *parent = NULL);

    //! Destroys the PulseAudioControl instance
    virtual ~PulseAudioControl();

signals:
    /*!
     * Sent when the current or maximum volume has changed.
     *
     * \param level The new volume level
     * \param maximum The maximum volume level
     */
    void volumeChanged(int volume, int maximum);

    /*!
     * Sent when main volume is set to so high that it can hurt hearing
     *
     * \param safeLevel Highest level for volume that does not risk hurting hearing
     */
    void highVolume(int safeLevel);

    /*!
     * Sent when user needs to be warned about long listening time.
     *
     * \param listeningTime listening time in minutes
     */
    void longListeningTime(int listeningTime);

    /*!
     * Sent when the call status has changed
     *
     * \param callActive \c true if a call is active, \c false otherwise
     */
    void callActiveChanged(bool callActive);

    void mediaStateChanged(const QString &state);

public slots:
    /*!
     * Queries the PulseAudio daemon for the volume levels (current and maximum).
     * If successful, volumeChanged signal will be emitted.
     */
    void update();

    /*!
     * Changes the volume level through the volume backend.
     *
     * \param volume The desired volume level
     */
    void setVolume(int volume);

private:
    //! Opens connection to PulseAudio daemon.
    void openConnection();

    /*!
     * Stores the current volume and the maximum volume.
     *
     * \param currentStep The current volume step
     * \param stepCount Number of volume steps
     */
    void setSteps(quint32 currentStep, quint32 stepCount);

    //! Registers a signal handler to listen to the PulseAudio MainVolume1 StepsUpdated signal
    void addSignalMatch();

    /*!
     * The signal handler for PulseAudio's MainVolume1 signal
     *
     * \param conn D-Bus connection structure
     * \param message signal message
     * \param control PulseAudioControl instance handling this signal
     */
    static DBusHandlerResult signalHandler(DBusConnection *conn, DBusMessage *message, void *control);

    //! D-Bus connection structure
    DBusConnection *dbusConnection;
    int reconnectTimeout;

    Q_DISABLE_COPY(PulseAudioControl)

#ifdef UNIT_TEST
    friend class Ut_PulseAudioControl;
#endif
};

#endif

