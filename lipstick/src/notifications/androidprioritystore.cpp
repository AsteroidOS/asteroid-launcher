/***************************************************************************
**
** Copyright (C) 2015 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
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

#include "androidprioritystore.h"

#include <QFile>
#include <QtDebug>

namespace {

const int InteractiveAndroidPriority = 120;
const int ElevatedAndroidPriority = 100;
const int StandardAndroidPriority = 50;

AndroidPriorityStore::PriorityDetails detailsForFeedback(const QString &feedback)
{
    if (!feedback.isEmpty()) {
        QStringList feedbackEntries = feedback.split(",", Qt::SkipEmptyParts);
        QSet<QString> tokens(feedbackEntries.begin(), feedbackEntries.end());

        // If the only feedback tokens are for email, this is a medium-priority notification
        tokens.remove(QStringLiteral("email"));
        tokens.remove(QStringLiteral("email_exists"));
        if (!tokens.isEmpty()) {
            // This is a top-priority notification
            return qMakePair(InteractiveAndroidPriority, feedback);
        }
    }
    return qMakePair(ElevatedAndroidPriority, feedback);
}

}

AndroidPriorityStore::AndroidPriorityStore(const QString &path, QObject *parent)
    : QObject(parent)
{
    QFile definitionFile(path);
    if (definitionFile.exists()) {
        if (definitionFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            while (!definitionFile.atEnd()) {
                const QByteArray lineChars(definitionFile.readLine());
                const QString line(QString::fromUtf8(lineChars.left(lineChars.length() - 1)));
                if (!line.isEmpty()) {
                    QString appName;
                    QString feedback;
                    int index = line.indexOf(QLatin1Char(';'));
                    if (index > 0) {
                        appName = line.left(index);
                        feedback = line.mid(index + 1);
                    } else {
                        appName = line;
                    }
                    priorityDefinitions.insert(appName, feedback);
                }
            }
        } else {
            qWarning() << Q_FUNC_INFO << "Unable to open file for reading:" << path;
        }
    } else {
        qWarning() << Q_FUNC_INFO << "No priority definition file exists:" << path;
    }
}

AndroidPriorityStore::PriorityDetails AndroidPriorityStore::appDetails(const QString &appName) const
{
    QHash<QString, QString>::const_iterator it = priorityDefinitions.constFind(appName);
    if (it != priorityDefinitions.constEnd()) {
        return detailsForFeedback(it.value());
    }
    return qMakePair(StandardAndroidPriority, QString());
}

AndroidPriorityStore::PriorityDetails AndroidPriorityStore::packageDetails(const QString &packageName) const
{
    const QString key(QStringLiteral("package:") + packageName);
    QHash<QString, QString>::const_iterator it = priorityDefinitions.constFind(key);
    if (it != priorityDefinitions.constEnd()) {
        return detailsForFeedback(it.value());
    }
    return qMakePair(StandardAndroidPriority, QString());
}

