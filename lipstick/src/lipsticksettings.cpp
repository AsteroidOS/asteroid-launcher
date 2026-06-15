
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
//

#include "screenlock/screenlock.h"
#include "homeapplication.h"
#include "lipsticksettings.h"

Q_GLOBAL_STATIC(LipstickSettings, settingsInstance)

LipstickSettings::LipstickSettings()
    : QObject()
    , screenLock(0)
{
}

LipstickSettings *LipstickSettings::instance()
{
    return settingsInstance();
}

void LipstickSettings::setScreenLock(ScreenLock *screenLock)
{
    // TODO: Disconnect from previous screenlock signals?

    this->screenLock = screenLock;
    connect(screenLock, SIGNAL(screenIsLocked(bool)), this, SIGNAL(lockscreenVisibleChanged()));
}

bool LipstickSettings::lockscreenVisible() const
{
    return screenLock != 0 ? screenLock->isScreenLocked() : false;
}

void LipstickSettings::setLockscreenVisible(bool lockscreenVisible)
{
    if (screenLock != 0 && lockscreenVisible != screenLock->isScreenLocked()) {
        if (lockscreenVisible) {
            screenLock->lockScreen();
        } else {
            screenLock->unlockScreen();
        }
    }
}

void LipstickSettings::lockScreen(bool immediate)
{
    if (screenLock != 0 && (!screenLock->isScreenLocked() || immediate)) {
        screenLock->lockScreen(immediate);
    }
}

