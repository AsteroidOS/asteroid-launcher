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

#ifndef VOLUMECONTROL_H
#define VOLUMECONTROL_H

#include <QTimer>
#include <QObject>

class HomeWindow;
class PulseAudioControl;
class VolumeKeyListener;
class MDConfItem;

/*!
 * \class VolumeControl
 *
 * \brief Shows a window for displaying the volume level.
 *
 * Creates a transparent window which can be used to show
 * the current volume level.
 */
class VolumeControl : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(int maximumVolume READ maximumVolume NOTIFY maximumVolumeChanged)
    Q_PROPERTY(int safeVolume READ safeVolume NOTIFY safeVolumeChanged)
    Q_PROPERTY(int restrictedVolume READ restrictedVolume NOTIFY restrictedVolumeChanged)
    Q_PROPERTY(bool windowVisible READ windowVisible WRITE setWindowVisible NOTIFY windowVisibleChanged)
    Q_PROPERTY(bool callActive READ callActive NOTIFY callActiveChanged)
    Q_PROPERTY(int mediaState READ mediaState NOTIFY mediaStateChanged)
    Q_ENUMS(MediaState)

public:
    enum MediaState {
        MediaStateUnknown,
        MediaStateInactive,
        MediaStateForeground,
        MediaStateBackground,
        MediaStateActive
    };

    /*!
     * Creates a volume controller.
     *
     * \param parent the parent object
     */
    explicit VolumeControl(QObject *parent = 0);

    /*!
     * Destroys the volume controller.
     */
    virtual ~VolumeControl();

    /*!
     * Returns the current volume.
     *
     * \return the current volume
     */
    int volume() const;

    /*!
     * Sets the current volume to \a volume.
     */
    void setVolume(int volume);

    /*!
     * Returns the maximum volume.
     *
     * \return the maximum volume
     */
    int maximumVolume() const;

    /*!
     * Returns the safe volume.
     *
     * \return the safe volume
     */
    int safeVolume() const;

    /*!
     * Returns the maximum volume that the system will allow. If the user has not acknowleged the
     * safe volume warning \l safeVolume() will be returned otherwise \l maximumVolume() will be
     * returned.
     *
     * \return the restricted volume
     */
    int restrictedVolume() const;

    /*!
     * Returns whether the volume window is visible or not.
     *
     * \return \c true if the volume window is visible, \c false otherwise
     */
    bool windowVisible() const;

    /*!
     * Sets the visibility of the volume window.
     *
     * \param visible \c true if the volume window should be visible, \c false otherwise
     */
    void setWindowVisible(bool visible);

    /*!
     * Returns whether a call is active or not.
     *
     * \return \c true if a call is active, \c false otherwise
     */
    bool callActive() const;

    int mediaState() const;

    //! \reimp
    virtual bool eventFilter(QObject *watched, QEvent *event);
    //! \reimp_end

signals:
    //! Sent when the volume has changed.
    void volumeChanged();

    //! Sent when a volume up/down key was pressed or released
    void volumeKeyPressed(int key);
    void volumeKeyReleased(int key);

    //! Sent when the maximum volume has changed.
    void maximumVolumeChanged();

    //! Sent when the safe volume has changed.
    void safeVolumeChanged();

    //! Sent when the restricted volume has changed.
    void restrictedVolumeChanged();

    //! Sent when the visibility of the volume window has changed.
    void windowVisibleChanged();

    //! Sent when the call activity status has changed.
    void callActiveChanged();

    void mediaStateChanged();

    /*!
     * Sent when high volume or long listening time warning should show to user.
     *
     * \param initial \c true if warning is initial, listening time == 0 \c false otherwise
     */
    void showAudioWarning(bool initial);

public slots:
    /*!
     * Sets the audio warning acknowledged.
     *
     * \param acknowledged \c true if the used has acknowledged warning, \c false otherwise.
     */
    void setWarningAcknowledged(bool acknowledged);

private slots:
    //! Sets the volume and maximum volume
    void setVolume(int volume, int maximumVolume);

    //! Used to capture safe volume level and reset it to safe when needed.
    void handleHighVolume(int safeLevel);

    //! Used to show long listening time warning
    void handleLongListeningTime(int listeningTime);

    //! Used to show call active status
    void handleCallActive(bool callActive);

    void handleMediaStateChanged(const QString &state);

    void createWindow();

private:
    //! Returns whether the audio warning has been acknowledged by user.
    bool warningAcknowledged() const;

    //! The volume control window
    HomeWindow *window;

    //! PulseAudio volume controller
    PulseAudioControl *pulseAudioControl;

    //! The current volume
    int volume_;

    //! The maximum volume
    int maximumVolume_;

    //! Stores audio warning acknowledgement state
    MDConfItem *audioWarning;

    //! The current safe volume
    int safeVolume_;

    //! Call active status
    bool callActive_;

    bool upPressed_;
    bool downPressed_;

    int mediaState_;

#ifdef UNIT_TEST
    friend class Ut_VolumeControl;
#endif
};

#endif // VOLUMECONTROL_H
