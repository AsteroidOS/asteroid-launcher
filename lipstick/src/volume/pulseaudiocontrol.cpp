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

#include "pulseaudiocontrol.h"
#include <QDBusMessage>
#include <QDBusConnection>
#include <QDBusArgument>
#include <dbus/dbus-glib-lowlevel.h>
#include <QTimer>
#include <QDebug>

#define DBUS_ERR_CHECK(err) \
    if (dbus_error_is_set(&err)) \
    { \
        qWarning() << err.message; \
        dbus_error_free(&err); \
    }

static const char *VOLUME_SERVICE = "com.Meego.MainVolume2";
static const char *VOLUME_PATH = "/com/meego/mainvolume2";
static const char *VOLUME_INTERFACE = "com.Meego.MainVolume2";

PulseAudioControl::PulseAudioControl(QObject *parent) :
    QObject(parent),
    dbusConnection(NULL),
    reconnectTimeout(2000) // first reconnect after 2000ms
{
}

PulseAudioControl::~PulseAudioControl()
{
    if (dbusConnection != NULL) {
        dbus_connection_remove_filter(dbusConnection, PulseAudioControl::signalHandler, (void *)this);
        dbus_connection_unref(dbusConnection);
    }
}

void PulseAudioControl::openConnection()
{
    //! If the connection already exists, do nothing
    if ((dbusConnection != NULL) && (dbus_connection_get_is_connected(dbusConnection))) {
        return;
    }

    // Establish a connection to the server
    char *pa_bus_address = getenv("PULSE_DBUS_SERVER");
    QByteArray addressArray;
    if (pa_bus_address == NULL) {
        QDBusMessage message = QDBusMessage::createMethodCall("org.pulseaudio.Server", "/org/pulseaudio/server_lookup1",
                                                              "org.freedesktop.DBus.Properties", "Get");
        message.setArguments(QVariantList() << "org.PulseAudio.ServerLookup1" << "Address");
        QDBusMessage reply = QDBusConnection::sessionBus().call(message);
        if (reply.type() == QDBusMessage::ReplyMessage && reply.arguments().count() > 0) {
            addressArray = reply.arguments().first().value<QDBusVariant>().variant().toString().toLatin1();
            pa_bus_address = addressArray.data();
        }
    }

    if (pa_bus_address != NULL) {
        DBusError dbus_err;
        dbus_error_init(&dbus_err);

        dbusConnection = dbus_connection_open(pa_bus_address, &dbus_err);

        DBUS_ERR_CHECK(dbus_err);
    }

    if (dbusConnection != NULL) {
        dbus_connection_setup_with_g_main(dbusConnection, NULL);
        dbus_connection_add_filter(dbusConnection, PulseAudioControl::signalHandler, (void *)this, NULL);

        addSignalMatch();
    }

    if (!dbusConnection) {
        QTimer::singleShot(reconnectTimeout, this, SLOT(update()));
        reconnectTimeout += 5000; // next reconnects wait for 5000ms more
    }
}

void PulseAudioControl::update()
{
    openConnection();

    if (dbusConnection == NULL) {
        return;
    }

    DBusError error;
    dbus_error_init(&error);

    DBusMessage *reply = NULL;
    DBusMessage *msg = dbus_message_new_method_call(VOLUME_SERVICE, VOLUME_PATH, "org.freedesktop.DBus.Properties", "GetAll");
    if (msg != NULL) {
        dbus_message_append_args(msg, DBUS_TYPE_STRING, &VOLUME_INTERFACE, DBUS_TYPE_INVALID);

        reply = dbus_connection_send_with_reply_and_block(dbusConnection, msg, -1, &error);

        DBUS_ERR_CHECK (error);

        dbus_message_unref(msg);
    }

    int currentStep = -1, stepCount = -1, highVolumeStep = -1;
    QString mediaState;

    if (reply != NULL) {
        if (dbus_message_get_type(reply) == DBUS_MESSAGE_TYPE_METHOD_RETURN) {
            DBusMessageIter iter;
            dbus_message_iter_init(reply, &iter);
            // Recurse into the array [array of dicts]
            while (dbus_message_iter_get_arg_type(&iter) != DBUS_TYPE_INVALID) {
                DBusMessageIter dict_entry;
                dbus_message_iter_recurse(&iter, &dict_entry);

                // Recurse into the dict [ dict_entry (string, variant) ]
                while (dbus_message_iter_get_arg_type(&dict_entry) != DBUS_TYPE_INVALID) {
                    DBusMessageIter in_dict;
                    // Recurse into the dict_entry [ string, variant ]
                    dbus_message_iter_recurse(&dict_entry, &in_dict);
                    {
                        const char *prop_name = NULL;
                        // Get the string value, "property name"
                        dbus_message_iter_get_basic(&in_dict, &prop_name);

                        dbus_message_iter_next(&in_dict);

                        DBusMessageIter variant;
                        // Recurse into the variant [ variant ]
                        dbus_message_iter_recurse(&in_dict, &variant);

                        if (prop_name == NULL) {
                        } else if (dbus_message_iter_get_arg_type(&variant) == DBUS_TYPE_UINT32) {
                            quint32 value;
                            dbus_message_iter_get_basic(&variant, &value);

                            if (strcmp(prop_name, "StepCount") == 0) {
                                stepCount = value;
                            } else if (strcmp(prop_name, "CurrentStep") == 0) {
                                currentStep = value;
                            } else if (strcmp(prop_name, "HighVolumeStep") == 0) {
                                highVolumeStep = value;
                            }
                        } else if (dbus_message_iter_get_arg_type(&variant) == DBUS_TYPE_STRING) {
                            const char *value = NULL;
                            dbus_message_iter_get_basic(&variant, &value);
                            if (strcmp(prop_name, "MediaState") == 0) {
                                mediaState = QString(value);
                            }
                        }
                    }

                    dbus_message_iter_next(&dict_entry);
                }
                dbus_message_iter_next(&iter);
            }
        }
        dbus_message_unref(reply);
    }

    if (currentStep != -1 && stepCount != -1) {
        setSteps(currentStep, stepCount);
    }

    if (highVolumeStep != -1) {
        emit highVolume(highVolumeStep);
    }

    if (!mediaState.isEmpty()) {
        emit mediaStateChanged(mediaState);
    }
}

void PulseAudioControl::addSignalMatch()
{
    static const char *signalNames []  = {"com.Meego.MainVolume2.StepsUpdated", "com.Meego.MainVolume2.NotifyHighVolume",
                                          "com.Meego.MainVolume2.NotifyListeningTime", "com.Meego.MainVolume2.CallStateChanged",
                                          "com.Meego.MainVolume2.MediaStateChanged"};
    for (int index = 0; index < 5; ++index) {
        DBusMessage *message = dbus_message_new_method_call(NULL, "/org/pulseaudio/core1", NULL, "ListenForSignal");
        if (message != NULL) {
            const char *signalPtr = signalNames[index];
            char **emptyarray = { NULL };
            dbus_message_append_args(message, DBUS_TYPE_STRING, &signalPtr, DBUS_TYPE_ARRAY, DBUS_TYPE_OBJECT_PATH,
                                     &emptyarray, 0, DBUS_TYPE_INVALID);
            dbus_connection_send(dbusConnection, message, NULL);
            dbus_message_unref(message);
        }
    }
}

DBusHandlerResult PulseAudioControl::signalHandler(DBusConnection *, DBusMessage *message, void *control)
{
    if (!message)
        return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;

    DBusError error;
    dbus_error_init(&error);

    if (dbus_message_has_member(message, "StepsUpdated")) {
        quint32 currentStep = 0;
        quint32 stepCount = 0;

        if (dbus_message_get_args(message, &error, DBUS_TYPE_UINT32, &stepCount, DBUS_TYPE_UINT32, &currentStep, DBUS_TYPE_INVALID)) {
            static_cast<PulseAudioControl*>(control)->setSteps(currentStep, stepCount);
        }
    } else if (dbus_message_has_member(message, "NotifyHighVolume")) {
        quint32 highestSafeVolume = 0;

        if (dbus_message_get_args(message, &error, DBUS_TYPE_UINT32, &highestSafeVolume, DBUS_TYPE_INVALID)) {
            static_cast<PulseAudioControl*>(control)->highVolume(highestSafeVolume);
        }
    } else if (dbus_message_has_member(message, "NotifyListeningTime")) {
        quint32 listeningTime = 0;

        if (dbus_message_get_args(message, &error, DBUS_TYPE_UINT32, &listeningTime, DBUS_TYPE_INVALID)) {
            static_cast<PulseAudioControl*>(control)->longListeningTime(listeningTime);
        }
    } else if (dbus_message_has_member(message, "CallStateChanged")) {
        const char *state;

        if (dbus_message_get_args(message, &error, DBUS_TYPE_STRING, &state, DBUS_TYPE_INVALID)) {
            emit static_cast<PulseAudioControl*>(control)->callActiveChanged(strcmp(state, "active") == 0);
        }
    } else if (dbus_message_has_member(message, "MediaStateChanged")) {
        const char *state;
        if (dbus_message_get_args(message, &error, DBUS_TYPE_STRING, &state, DBUS_TYPE_INVALID)) {
            emit static_cast<PulseAudioControl*>(control)->mediaStateChanged(QString(state));
        }
    }

    DBUS_ERR_CHECK (error);
    return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;
}

void PulseAudioControl::setSteps(quint32 currentStep, quint32 stepCount)
{
    // The pulseaudio API reports the step count (starting from 0), so the maximum volume is stepCount - 1
    emit volumeChanged(currentStep, stepCount - 1);
}

void PulseAudioControl::setVolume(int volume)
{
    // Check the connection, maybe PulseAudio restarted meanwhile
    openConnection();

    // Don't try to set the volume via D-bus when it isn't available
    if (dbusConnection == NULL) {
        return;
    }

    DBusMessage *message = dbus_message_new_method_call(VOLUME_SERVICE, VOLUME_PATH, "org.freedesktop.DBus.Properties", "Set");
    if (message != NULL) {
        static const char *method = "CurrentStep";
        if (dbus_message_append_args(message, DBUS_TYPE_STRING, &VOLUME_INTERFACE, DBUS_TYPE_STRING, &method, DBUS_TYPE_INVALID)) {
            DBusMessageIter append;
            DBusMessageIter sub;

            // Create and append the variant argument ...
            dbus_message_iter_init_append(message, &append);

            dbus_message_iter_open_container(&append, DBUS_TYPE_VARIANT, DBUS_TYPE_UINT32_AS_STRING, &sub);
            // Set the variant argument value:
            dbus_message_iter_append_basic(&sub, DBUS_TYPE_UINT32, &volume);
            // Close the append iterator
            dbus_message_iter_close_container(&append, &sub);

            // Send/flush the message immediately:
            dbus_connection_send(dbusConnection, message, NULL);
        }

        dbus_message_unref(message);
    }
}
