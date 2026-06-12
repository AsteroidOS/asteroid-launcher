
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
// Copyright (c) 2012, Robin Burchell <robin+nemo@viroteck.net>

#ifndef LIPSTICKSETTINGS_H
#define LIPSTICKSETTINGS_H

#include <QObject>
#include <QMetaType>
#include <QSize>
#include "lipstickglobal.h"

class ScreenLock;

class LIPSTICK_EXPORT LipstickSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool lockscreenVisible READ lockscreenVisible WRITE setLockscreenVisible NOTIFY lockscreenVisibleChanged)
    Q_PROPERTY(bool lowPowerMode READ lowPowerMode NOTIFY lowPowerModeChanged)
    Q_PROPERTY(QSize screenSize READ screenSize NOTIFY screenSizeChanged)
    Q_PROPERTY(QString blankingPolicy READ blankingPolicy NOTIFY blankingPolicyChanged)

public:
    explicit LipstickSettings();
    static LipstickSettings *instance();

    void setScreenLock(ScreenLock *screenLock);
    bool lockscreenVisible() const;
    void setLockscreenVisible(bool lockscreenVisible);

    bool lowPowerMode() const;

    QSize screenSize();
    void exportScreenSize();

    QString blankingPolicy();

    Q_INVOKABLE void lockScreen(bool immediate);

signals:
    void lockscreenVisibleChanged();
    void lowPowerModeChanged();
    void screenSizeChanged();
    void blankingPolicyChanged();

private:
    //! Logic for locking and unlocking the screen
    ScreenLock *screenLock;
};

Q_DECLARE_METATYPE(LipstickSettings *)

#endif // LIPSTICKSETTINGS_H

