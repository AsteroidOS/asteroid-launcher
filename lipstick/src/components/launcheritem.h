
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
// Copyright (c) 2011, Robin Burchell
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>

#ifndef LAUNCHERITEM_H
#define LAUNCHERITEM_H

#include <QObject>
#include <QStringList>
#include <QSharedPointer>
#include <QBasicTimer>

// Define this if you'd like to see debug messages from the launcher
#ifdef DEBUG_LAUNCHER
#include <QDebug>
#define LAUNCHER_DEBUG(things) qDebug() << Q_FUNC_INFO << things
#else
#define LAUNCHER_DEBUG(things)
#endif

#include "launchermodel.h"

class MDesktopEntry;

class LauncherItem : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(LauncherItem)

    Q_PROPERTY(LauncherModel::ItemType type READ type CONSTANT)
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY itemChanged)
    Q_PROPERTY(QString fileID READ fileID NOTIFY itemChanged)
    Q_PROPERTY(QString exec READ exec NOTIFY itemChanged)
    Q_PROPERTY(QString title READ title NOTIFY itemChanged)
    Q_PROPERTY(QString entryType READ entryType NOTIFY itemChanged)
    Q_PROPERTY(QString iconId READ iconId NOTIFY itemChanged)
    Q_PROPERTY(QStringList desktopCategories READ desktopCategories NOTIFY itemChanged)
    Q_PROPERTY(QString titleUnlocalized READ titleUnlocalized NOTIFY itemChanged)
    Q_PROPERTY(bool shouldDisplay READ shouldDisplay NOTIFY itemChanged)
    Q_PROPERTY(bool isValid READ isValid NOTIFY itemChanged)
    Q_PROPERTY(bool isLaunching READ isLaunching WRITE setIsLaunching NOTIFY isLaunchingChanged)

    QSharedPointer<MDesktopEntry> _desktopEntry;
    QBasicTimer _launchingTimeout;
    bool _isLaunching;
    QString _customTitle;
    QString _customIconFilename;
    int _serial;

public slots:
    void setIsLaunching(bool isLaunching = false);

public:
    explicit LauncherItem(const QString &filePath = QString(), QObject *parent = 0);
    virtual ~LauncherItem();

    LauncherModel::ItemType type() const;
    void setFilePath(const QString &filePath);
    QString filePath() const;
    QString fileID() const;
    QString filename() const;
    QString exec() const;
    QString title() const;
    QString entryType() const;
    QString iconId() const;
    QStringList desktopCategories() const;
    QString titleUnlocalized() const;
    bool shouldDisplay() const;
    bool isValid() const;
    bool isLaunching() const;
    bool isStillValid();

    QString getOriginalIconId() const;
    void setIconFilename(const QString &path);
    QString iconFilename() const;

    Q_INVOKABLE void launchApplication();

    void setCustomTitle(QString customTitle);

    Q_INVOKABLE QString readValue(const QString &key) const;

signals:
    void itemChanged();
    void isLaunchingChanged();

protected:
    void timerEvent(QTimerEvent *event);
};

#endif // LAUNCHERITEM_H
