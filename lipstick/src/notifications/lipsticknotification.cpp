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

#include "notificationmanager.h"
#include "lipsticknotification.h"

#include <QDBusArgument>
#include <QtDebug>
#include <QDataStream>

LipstickNotification::LipstickNotification(const QString &appName, uint replacesId, const QString &appIcon, const QString &summary, const QString &body, const QStringList &actions, const QVariantHash &hints, int expireTimeout, QObject *parent) :
    QObject(parent),
    appName_(appName),
    replacesId_(replacesId),
    appIcon_(appIcon),
    summary_(summary),
    body_(body),
    actions_(actions),
    hints_(hints),
    expireTimeout_(expireTimeout),
    priority_(hints.value(NotificationManager::HINT_PRIORITY).toInt()),
    timestamp_(hints.value(NotificationManager::HINT_TIMESTAMP).toDateTime().toMSecsSinceEpoch())
{
    updateHintValues();
}

LipstickNotification::LipstickNotification(QObject *parent) :
    QObject(parent),
    replacesId_(0),
    expireTimeout_(-1),
    priority_(0),
    timestamp_(0)
{
}

LipstickNotification::LipstickNotification(const LipstickNotification &notification) :
    QObject(notification.parent()),
    appName_(notification.appName_),
    replacesId_(notification.replacesId_),
    appIcon_(notification.appIcon_),
    summary_(notification.summary_),
    body_(notification.body_),
    actions_(notification.actions_),
    hints_(notification.hints_),
    hintValues_(notification.hintValues_),
    expireTimeout_(notification.expireTimeout_),
    priority_(notification.priority_),
    timestamp_(notification.timestamp_)
{
}

QString LipstickNotification::appName() const
{
    return appName_;
}

void LipstickNotification::setAppName(const QString &appName)
{
    appName_ = appName;
}

uint LipstickNotification::replacesId() const
{
    return replacesId_;
}

QString LipstickNotification::appIcon() const
{
    return appIcon_;
}

void LipstickNotification::setAppIcon(const QString &appIcon)
{
    appIcon_ = appIcon;
}

QString LipstickNotification::summary() const
{
    return summary_;
}

void LipstickNotification::setSummary(const QString &summary)
{
    if (summary_ != summary) {
        summary_ = summary;
        emit summaryChanged();
    }
}

QString LipstickNotification::body() const
{
    return body_;
}

void LipstickNotification::setBody(const QString &body)
{
    if (body_ != body) {
        body_ = body;
        emit bodyChanged();
    }
}

QStringList LipstickNotification::actions() const
{
    return actions_;
}

void LipstickNotification::setActions(const QStringList &actions)
{
    actions_ = actions;
}

QVariantHash LipstickNotification::hints() const
{
    return hints_;
}

QVariantMap LipstickNotification::hintValues() const
{
    return hintValues_;
}

void LipstickNotification::setHints(const QVariantHash &hints)
{
    QString oldIcon = icon();
    quint64 oldTimestamp = timestamp_;
    QString oldPreviewIcon = previewIcon();
    QString oldPreviewSummary = previewSummary();
    QString oldPreviewBody = previewBody();
    int oldUrgency = urgency();
    int oldItemCount = itemCount();
    int oldPriority = priority_;
    QString oldCategory = category();

    hints_ = hints;
    updateHintValues();

    if (oldIcon != icon()) {
        emit iconChanged();
    }

    timestamp_ = hints_.value(NotificationManager::HINT_TIMESTAMP).toDateTime().toMSecsSinceEpoch();
    if (oldTimestamp != timestamp_) {
        emit timestampChanged();
    }

    if (oldPreviewIcon != previewIcon()) {
        emit previewIconChanged();
    }

    if (oldPreviewSummary != previewSummary()) {
        emit previewSummaryChanged();
    }

    if (oldPreviewBody != previewBody()) {
        emit previewBodyChanged();
    }

    if (oldUrgency != urgency()) {
        emit urgencyChanged();
    }

    if (oldItemCount != itemCount()) {
        emit itemCountChanged();
    }

    priority_ = hints_.value(NotificationManager::HINT_PRIORITY).toInt();
    if (oldPriority != priority_) {
        emit priorityChanged();
    }

    if (oldCategory != category()) {
        emit categoryChanged();
    }

    emit hintsChanged();
}

int LipstickNotification::expireTimeout() const
{
    return expireTimeout_;
}

void LipstickNotification::setExpireTimeout(int expireTimeout)
{
    expireTimeout_ = expireTimeout;
}

QString LipstickNotification::icon() const
{
    QString rv(hints_.value(NotificationManager::HINT_ICON).toString());
    if (rv.isEmpty()) {
        rv = hints_.value(NotificationManager::HINT_IMAGE_PATH).toString();
    }
    return rv;
}

QDateTime LipstickNotification::timestamp() const
{
    return QDateTime::fromMSecsSinceEpoch(timestamp_);
}

QString LipstickNotification::previewIcon() const
{
    return hints_.value(NotificationManager::HINT_PREVIEW_ICON).toString();
}

QString LipstickNotification::previewSummary() const
{
    return hints_.value(NotificationManager::HINT_PREVIEW_SUMMARY).toString();
}

QString LipstickNotification::previewBody() const
{
    return hints_.value(NotificationManager::HINT_PREVIEW_BODY).toString();
}

int LipstickNotification::urgency() const
{
    return hints_.value(NotificationManager::HINT_URGENCY).toInt();
}

int LipstickNotification::itemCount() const
{
    return hints_.value(NotificationManager::HINT_ITEM_COUNT).toInt();
}

int LipstickNotification::priority() const
{
    return priority_;
}

QString LipstickNotification::category() const
{
    return hints_.value(NotificationManager::HINT_CATEGORY).toString();
}

bool LipstickNotification::isUserRemovable() const
{
    return hints_.value(NotificationManager::HINT_USER_REMOVABLE, QVariant(true)).toBool();
}

bool LipstickNotification::hidden() const
{
    return hints_.value(NotificationManager::HINT_HIDDEN, QVariant(false)).toBool();
}

QVariantList LipstickNotification::remoteActions() const
{
    QVariantList rv;

    QStringList::const_iterator it = actions_.constBegin(), end = actions_.constEnd();
    while (it != end) {
        const QString name(*it);
        QString displayName;
        if (++it != end) {
            displayName = *it;
            ++it;
        }

        const QString hint(hints_.value(NotificationManager::HINT_REMOTE_ACTION_PREFIX + name).toString());
        if (!hint.isEmpty()) {
            const QString icon(hints_.value(NotificationManager::HINT_REMOTE_ACTION_ICON_PREFIX + name).toString());

            QVariantMap vm;
            vm.insert(QStringLiteral("name"), name);
            if (!displayName.isEmpty()) {
                vm.insert(QStringLiteral("displayName"), displayName);
            }
            if (!icon.isEmpty()) {
                vm.insert(QStringLiteral("icon"), icon);
            }

            // Extract the element of the DBus call
            QStringList elements(hint.split(' ', Qt::SkipEmptyParts));
            if (elements.size() <= 3) {
                qWarning() << "Unable to decode invalid remote action:" << hint;
            } else {
                int index = 0;
                vm.insert(QStringLiteral("service"), elements.at(index++));
                vm.insert(QStringLiteral("path"), elements.at(index++));
                vm.insert(QStringLiteral("iface"), elements.at(index++));
                vm.insert(QStringLiteral("method"), elements.at(index++));

                QVariantList args;
                while (index < elements.size()) {
                    const QString &arg(elements.at(index++));
                    const QByteArray buffer(QByteArray::fromBase64(arg.toUtf8()));

                    QDataStream stream(buffer);
                    QVariant var;
                    stream >> var;
                    args.append(var);
                }
                vm.insert(QStringLiteral("arguments"), args);
            }

            rv.append(vm);
        }
    }

    return rv;
}

QString LipstickNotification::origin() const
{
    return hints_.value(NotificationManager::HINT_ORIGIN).toString();
}

QString LipstickNotification::owner() const
{
    return hints_.value(NotificationManager::HINT_OWNER).toString();
}

int LipstickNotification::maxContentLines() const
{
    return hints_.value(NotificationManager::HINT_MAX_CONTENT_LINES).toInt();
}

bool LipstickNotification::restored() const
{
    return hints_.value(NotificationManager::HINT_RESTORED).toBool();
}

quint64 LipstickNotification::internalTimestamp() const
{
    return timestamp_;
}

void LipstickNotification::updateHintValues()
{
    hintValues_.clear();

    QVariantHash::const_iterator it = hints_.constBegin(), end = hints_.constEnd();
    for ( ; it != end; ++it) {
        // Filter out the hints that are represented by other properties
        const QString &hint(it.key());
        if (hint.compare(NotificationManager::HINT_ICON, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_IMAGE_PATH, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_TIMESTAMP, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_PREVIEW_ICON, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_PREVIEW_SUMMARY, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_PREVIEW_BODY, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_URGENCY, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_ITEM_COUNT, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_PRIORITY, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_CATEGORY, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_USER_REMOVABLE, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_HIDDEN, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_ORIGIN, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_OWNER, Qt::CaseInsensitive) != 0 &&
            hint.compare(NotificationManager::HINT_MAX_CONTENT_LINES, Qt::CaseInsensitive) != 0 &&
            !hint.startsWith(NotificationManager::HINT_REMOTE_ACTION_PREFIX, Qt::CaseInsensitive) &&
            !hint.startsWith(NotificationManager::HINT_REMOTE_ACTION_ICON_PREFIX, Qt::CaseInsensitive)) {
            hintValues_.insert(hint, it.value());
        }
    }
}

QDBusArgument &operator<<(QDBusArgument &argument, const LipstickNotification &notification)
{
    argument.beginStructure();
    argument << notification.appName_;
    argument << notification.replacesId_;
    argument << notification.appIcon_;
    argument << notification.summary_;
    argument << notification.body_;
    argument << notification.actions_;
    argument << notification.hints_;
    argument << notification.expireTimeout_;
    argument.endStructure();
    return argument;
}

const QDBusArgument &operator>>(const QDBusArgument &argument, LipstickNotification &notification)
{
    argument.beginStructure();
    argument >> notification.appName_;
    argument >> notification.replacesId_;
    argument >> notification.appIcon_;
    argument >> notification.summary_;
    argument >> notification.body_;
    argument >> notification.actions_;
    argument >> notification.hints_;
    argument >> notification.expireTimeout_;
    argument.endStructure();

    notification.priority_ = notification.hints_.value(NotificationManager::HINT_PRIORITY).toInt();
    notification.timestamp_ = notification.hints_.value(NotificationManager::HINT_TIMESTAMP).toDateTime().toMSecsSinceEpoch();
    notification.updateHintValues();

    return argument;
}

namespace {

int comparePriority(const LipstickNotification &lhs, const LipstickNotification &rhs)
{
    const int lhsPriority(lhs.priority()), rhsPriority(rhs.priority());
    if (lhsPriority < rhsPriority) {
        return -1;
    }
    if (rhsPriority < lhsPriority) {
        return 1;
    }
    return 0;
}

int compareTimestamp(const LipstickNotification &lhs, const LipstickNotification &rhs)
{
    const quint64 lhsTimestamp(lhs.internalTimestamp()), rhsTimestamp(rhs.internalTimestamp());
    if (lhsTimestamp < rhsTimestamp) {
        return -1;
    }
    if (rhsTimestamp < lhsTimestamp) {
        return 1;
    }
    return 0;
}

}

bool operator<(const LipstickNotification &lhs, const LipstickNotification &rhs)
{
    int priorityComparison(comparePriority(lhs, rhs));
    if (priorityComparison > 0) {
        // Higher priority notifications sort first
        return true;
    } else if (priorityComparison == 0) {
        int timestampComparison(compareTimestamp(lhs, rhs));
        if (timestampComparison > 0) {
            // Later notifications sort first
            return true;
        } else if (timestampComparison == 0) {
            // For matching timestamps, sort the higher ID first
            if (lhs.replacesId() > rhs.replacesId()) {
                return true;
            }
        }
    }
    return false;
}

NotificationList::NotificationList()
{
}

NotificationList::NotificationList(const QList<LipstickNotification *> &notificationList) :
    notificationList(notificationList)
{
}

NotificationList::NotificationList(const NotificationList &notificationList) :
    notificationList(notificationList.notificationList)
{
}

QList<LipstickNotification *> NotificationList::notifications() const
{
    return notificationList;
}

QDBusArgument &operator<<(QDBusArgument &argument, const NotificationList &notificationList)
{
    argument.beginArray(qMetaTypeId<LipstickNotification>());
    foreach (LipstickNotification *notification, notificationList.notificationList) {
        argument << *notification;
    }
    argument.endArray();
    return argument;
}

const QDBusArgument &operator>>(const QDBusArgument &argument, NotificationList &notificationList)
{
    argument.beginArray();
    notificationList.notificationList.clear();
    while (!argument.atEnd()) {
        LipstickNotification *notification = new LipstickNotification;
        argument >> *notification;
        notificationList.notificationList.append(notification);
    }
    argument.endArray();
    return argument;
}
