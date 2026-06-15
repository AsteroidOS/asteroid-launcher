
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

class ScreenLock;

class LipstickSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool lockscreenVisible READ lockscreenVisible WRITE setLockscreenVisible NOTIFY lockscreenVisibleChanged)

public:
    explicit LipstickSettings();
    static LipstickSettings *instance();

    void setScreenLock(ScreenLock *screenLock);
    bool lockscreenVisible() const;
    void setLockscreenVisible(bool lockscreenVisible);

    Q_INVOKABLE void lockScreen(bool immediate);

signals:
    void lockscreenVisibleChanged();

private:
    //! Logic for locking and unlocking the screen
    ScreenLock *screenLock;
};

Q_DECLARE_METATYPE(LipstickSettings *)

#endif // LIPSTICKSETTINGS_H

