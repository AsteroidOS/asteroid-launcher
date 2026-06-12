/*
 * Copyright (C) 2017 - Florent Revest <revestflo@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef BLUETOOTHAGENT_H
#define BLUETOOTHAGENT_H

#include <QObject>
#include <QDBusConnection>
#include <QDBusContext>
#include <QDBusObjectPath>
#include <QDBusServiceWatcher>
#include <QDBusMessage>
#include "lipstickglobal.h"

class HomeWindow;

class LIPSTICK_EXPORT BluetoothAgent : public QObject, protected QDBusContext
{
    Q_OBJECT
    Q_ENUMS(State);
    Q_CLASSINFO("D-Bus Interface", "org.bluez.Agent1")
    Q_PROPERTY(bool windowVisible READ windowVisible WRITE setWindowVisible NOTIFY windowVisibleChanged)

    Q_PROPERTY(State state READ getState NOTIFY stateChanged)
    Q_PROPERTY(QString pinCode READ getPinCode WRITE setPinCode NOTIFY pinCodeChanged)
    Q_PROPERTY(quint32 passkey READ getPasskey WRITE setPasskey NOTIFY passkeyChanged)

public:
    Q_INVOKABLE void userAccepts();
    Q_INVOKABLE void userCancels();

    BluetoothAgent(QObject *parent = 0);
    QDBusObjectPath getPath();

    bool windowVisible() const;
    void setWindowVisible(bool visible);

    enum State
    {
        Idle,
        ReqPinCode,
        ReqPasskey,
        DispPinCode,
        DispPasskey,
        ReqConfirmation,
        ReqAuthorization,
        AuthService
    };

    State getState();
    void setState(State s);

    QString getPinCode();
    void setPinCode(QString);

    quint32 getPasskey();
    void setPasskey(quint32);

signals:
    void windowVisibleChanged();
    void stateChanged();
    void pinCodeChanged();
    void passkeyChanged();

private:
    QDBusInterface *m_mceDbus;
    QString mPath;
    HomeWindow *window;
    State state;
    bool reqConfirm, reqAuth;
    QString pinCode;
    quint32 passkey;
    QDBusObjectPath device;
    QDBusServiceWatcher *mWatcher;
    QDBusMessage m_latestMessage;

    void setTrusted(QDBusObjectPath path);
    void reject();

private slots:
    void serviceRegistered(const QString& name);
    void serviceUnregistered(const QString& name);

public slots:
    void Release();
    QString RequestPinCode(QDBusObjectPath object, const QDBusMessage &message);
    void DisplayPinCode(QDBusObjectPath object, QString pinCode);
    quint32 RequestPasskey(QDBusObjectPath object, const QDBusMessage &message);
    void DisplayPasskey(QDBusObjectPath object, quint32 passkey, quint16 entered);
    void RequestConfirmation(QDBusObjectPath object, quint32 passKey, const QDBusMessage &message);
    void RequestAuthorization(QDBusObjectPath object, const QDBusMessage &message);
    void AuthorizeService(QDBusObjectPath object, QString uuid, const QDBusMessage &message);
    void Cancel();
};

#endif // BLUETOOTHAGENT_H
