/*
 * Copyright (C) 2017 Florent Revest <revestflo@gmail.com>
 * All rights reserved.
 *
 * You may use this file under the terms of BSD license as follows:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the author nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "notificationsnoozer.h"

#include <timed-qt5/event>
#include <timed-qt5/interface>

bool NotificationSnoozer::snooze(LipstickNotification *notif, int minutes)
{
    /* Build a notificationtool command to be triggered later */
    QString notifCmd;
    QTextStream cmdStream(&notifCmd);

    cmdStream << "/usr/bin/notificationtool -o add";

    const QVariantHash hints(notif->hints());
    QVariantHash::const_iterator hit = hints.constBegin(), hend = hints.constEnd();
    for( ; hit != hend; ++hit)
        cmdStream << " --hint=\"" << hit.key() << " " << hit.value().toString() << "\"";

    cmdStream << " --application=\"" << notif->appName() << "\"";
    cmdStream << " --icon=\"" << notif->appIcon() << "\"";
    cmdStream << " --timeout=\"" << notif->expireTimeout() << "\"";
    cmdStream << " \"" << notif->summary() << "\"";
    cmdStream << " \"" << notif->body() << "\"";

    /* Build a timed countdown that will run the notificationtool command */
    Maemo::Timed::Interface interface;
    Maemo::Timed::Event event;

    if(!interface.isValid())
        return false;

    Maemo::Timed::Event::Action &act = event.addAction();
    act.whenDue();
    act.runCommand(notifCmd.toLatin1().data(), "ceres");

    event.setAttribute("APPLICATION", "launcher");
    event.setAttribute("type", "countdown");
    event.setAttribute("timeOfDay", "1");
    event.setTicker(time(NULL) + 60*minutes);

    QDBusReply<uint> res = interface.add_event_sync(event);
    return res.isValid();
}

