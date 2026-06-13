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

#include <QDBusInterface>
#include <QDBusPendingCall>
#include <QDBusVariant>

#include "bluetoothagent.h"

#define AGENT_CAPABILITY        "DisplayYesNo"

BluetoothAgent::BluetoothAgent(QObject *parent) : QObject(parent)
{
    m_mceDbus = new QDBusInterface("com.nokia.mce", "/com/nokia/mce/request", "com.nokia.mce.request", QDBusConnection::systemBus());
    QDBusConnection bus = QDBusConnection::systemBus();
    mPath = "/org/nemomobile/lipstick/agent";
    bus.registerObject(mPath, this, QDBusConnection::ExportAllSlots | QDBusConnection::ExportAllProperties);

    mWatcher = new QDBusServiceWatcher("org.bluez", bus);
    connect(mWatcher, SIGNAL(serviceRegistered(const QString&)), this, SLOT(serviceRegistered(const QString&)));
    connect(mWatcher, SIGNAL(serviceUnregistered(const QString&)), this, SLOT(serviceUnregistered(const QString&)));

    QDBusInterface remoteOm("org.bluez", "/", "org.bluez.AgentManager1", bus);
    if(remoteOm.isValid())
        serviceRegistered("org.bluez");

    state = Idle;
    pinCode = "";
    passkey = 0;
}

void BluetoothAgent::serviceRegistered(const QString&)
{
    QDBusInterface agentManager("org.bluez", "/org/bluez", "org.bluez.AgentManager1", QDBusConnection::systemBus());
    agentManager.call("RegisterAgent", QVariant::fromValue(getPath()), AGENT_CAPABILITY);
    agentManager.asyncCall("RequestDefaultAgent", QVariant::fromValue(getPath()));
}

void BluetoothAgent::serviceUnregistered(const QString&)
{
    setWindowVisible(false);
    setState(Idle);
}

void BluetoothAgent::setTrusted(QDBusObjectPath path)
{
    QDBusInterface device("org.bluez", path.path(), "org.freedesktop.DBus.Properties", QDBusConnection::systemBus());
    device.asyncCall("Set", "org.bluez.Device1", "Trusted", true);
}

void BluetoothAgent::reject()
{
    QDBusMessage pendingErrorReply = m_latestMessage.createErrorReply("org.bluez.Error.Rejected", "Rejected");
    QDBusConnection::systemBus().send(pendingErrorReply);
}

QDBusObjectPath BluetoothAgent::getPath()
{
    return QDBusObjectPath(mPath);
}

BluetoothAgent::State BluetoothAgent::getState()
{
    return state;
}

void BluetoothAgent::setState(State s)
{
    if(state != s) {
        state = s;
        emit stateChanged();
    }
}

QString BluetoothAgent::getPinCode()
{
    return pinCode;
}

void BluetoothAgent::setPinCode(QString s)
{
    if(pinCode != s) {
        pinCode = s;
        emit pinCodeChanged();
    }
}

quint32 BluetoothAgent::getPasskey()
{
    return passkey;
}

void BluetoothAgent::setPasskey(quint32 pk)
{
    if(passkey != pk) {
        passkey = pk;
        emit passkeyChanged();
    }
}

bool BluetoothAgent::windowVisible() const
{
    return m_visible;
}

void BluetoothAgent::setWindowVisible(bool visible)
{
    if (visible == m_visible)
        return;

    m_visible = visible;
    if (visible) {
        // Keep the screen on and unlocked for the duration of the pairing
        m_mceDbus->asyncCall("set_config", QDBusObjectPath("/system/osso/dsm/display/inhibit_blank_mode").path(), QVariant::fromValue(QDBusVariant(3)));
        m_mceDbus->asyncCall("req_tklock_mode_change", "unlocked");
        m_mceDbus->asyncCall("set_config", QDBusObjectPath("/system/osso/dsm/locks/tklock_blank_disable").path(), QVariant::fromValue(QDBusVariant(1)));
    } else {
        m_mceDbus->asyncCall("set_config", QDBusObjectPath("/system/osso/dsm/display/inhibit_blank_mode").path(), QVariant::fromValue(QDBusVariant(0)));
        m_mceDbus->asyncCall("req_tklock_mode_change", "locked");
        m_mceDbus->asyncCall("set_config", QDBusObjectPath("/system/osso/dsm/locks/tklock_blank_disable").path(), QVariant::fromValue(QDBusVariant(0)));
    }
    emit windowVisibleChanged();
}

void BluetoothAgent::userAccepts()
{
    QDBusMessage pendingReply = m_latestMessage.createReply();
    if(state == ReqPinCode)
        pendingReply << pinCode;
    else if(state == ReqPasskey)
        pendingReply << passkey;
    else if(state == ReqConfirmation)
        setTrusted(device);

    if(state == ReqPinCode || state == ReqPasskey || state == ReqConfirmation
        || state == ReqAuthorization || state == AuthService)
        QDBusConnection::systemBus().send(pendingReply);

    setState(Idle);
}

void BluetoothAgent::userCancels()
{
    reject();
    setState(Idle);
}

/* Exposed slots */
QString BluetoothAgent::RequestPinCode(QDBusObjectPath object, const QDBusMessage &message)
{
    device = object;
    setTrusted(device);
    setWindowVisible(true);
    setState(ReqPinCode);

    message.setDelayedReply(true);

    return "";
}

quint32 BluetoothAgent::RequestPasskey(QDBusObjectPath object, const QDBusMessage &message)
{
    device = object;
    setTrusted(device);
    setWindowVisible(true);
    setState(ReqPasskey);

    message.setDelayedReply(true);

    return 0;
}

void BluetoothAgent::DisplayPinCode(QDBusObjectPath object, QString pc)
{
    device = object;
    setPinCode(pc);
    setWindowVisible(true);
    setState(DispPinCode);
}

void BluetoothAgent::DisplayPasskey(QDBusObjectPath object, quint32 pk, quint16)
{
    device = object;
    setPasskey(pk);
    setWindowVisible(true);
    setState(DispPasskey);
}

void BluetoothAgent::RequestConfirmation(QDBusObjectPath object, quint32 pk, const QDBusMessage &message)
{
    device = object;
    setPasskey(pk);
    setWindowVisible(true);
    setState(ReqConfirmation);

    message.setDelayedReply(true);

    m_latestMessage = message;
}

void BluetoothAgent::RequestAuthorization(QDBusObjectPath object, const QDBusMessage &message)
{
    device = object;
    setWindowVisible(true);
    setState(ReqAuthorization);

    message.setDelayedReply(true);

    m_latestMessage = message;
}

void BluetoothAgent::AuthorizeService(QDBusObjectPath object, QString uuid, const QDBusMessage &message)
{
    device = object;
    setWindowVisible(true);
    setState(AuthService);
    setPinCode(uuid);

    message.setDelayedReply(true);

    m_latestMessage = message;
}

void BluetoothAgent::Cancel()
{
    setWindowVisible(false);
    setState(Idle);
}

void BluetoothAgent::Release()
{
    setWindowVisible(false);
    setState(Idle);
}

