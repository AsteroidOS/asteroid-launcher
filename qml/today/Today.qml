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

import QtQuick 2.9
import org.asteroid.controls 1.0
import org.nemomobile.calendar 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.time 1.0
import 'weathericons.js' as IconTools

ListView {
    boundsBehavior: Flickable.StopAtBounds

    WallClock {
        id: todayClock
        enabled: true
        updateFrequency: WallClock.Day
    }

    property int year: todayClock.time.getFullYear()
    property int month: todayClock.time.getMonth()+1
    property int day: todayClock.time.getDate()

    ConfigurationValue {
        id: timestampDay0
        key: "/org/asteroidos/weather/timestamp-day0"
        defaultValue: 0
    }

    ConfigurationValue {
        id: use12H
        key: "/org/asteroidos/settings/use-12h-format"
        defaultValue: false
    }

    ConfigurationValue {
        id: useFahrenheit
        key: "/org/asteroidos/settings/use-fahrenheit"
        defaultValue: false
    }

    property bool weatherAvailable: {
        var day0Date    = new Date(timestampDay0.value*1000);
        var daysDiff = Math.round((todayClock.time-day0Date)/(1000*60*60*24));
        return daysDiff < 5
    }

    property int dayNb: {
        var day0Date    = new Date(timestampDay0.value*1000);
        var daysDiff = Math.round((todayClock.time-day0Date)/(1000*60*60*24));
        if(daysDiff > 5) daysDiff = 5;
        return daysDiff;
    }

    function convertTemp(val) {
        var celsius = (val-273);
        if(!useFahrenheit.value)
            return celsius + "°C";
        else
            return Math.round(((celsius)*9/5) + 32) + "°F";
    }

    ConfigurationValue {
        id: owmId
        key: "/org/asteroidos/weather/day" + dayNb + "/id"
        defaultValue: ""
    }
    ConfigurationValue {
        id: minTemp
        key: "/org/asteroidos/weather/day" + dayNb + "/min-temp"
        defaultValue: 273
    }
    ConfigurationValue {
        id: maxTemp
        key: "/org/asteroidos/weather/day" + dayNb + "/max-temp"
        defaultValue: 273
    }

    footer: Item { height: Dims.h(25) }
    header: Item {
        width: parent.width
        height: Dims.h(25)

        Icon {
            name: IconTools.getIconName(owmId.value)
            height: Dims.h(20)
            width: height
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.horizontalCenter
            opacity: 0.8
            visible: weatherAvailable
        }

        Label {
            height: parent.height
            width: Dims.w(45)
            anchors.right: parent.right
            text: convertTemp(minTemp.value) + "\n" + convertTemp(maxTemp.value)
            opacity: 0.8
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Dims.l(5)
            visible: weatherAvailable
        }
    }

    model: AgendaModel {
        id: agendaModel
        startDate: new Date(year, month, day)
        endDate: startDate
    }

    delegate: Component {
        Item {
            height: Dims.h(25)
            width: parent.width

            Label {
                id: hour
                text: model.occurrence.startTime.toLocaleString(Qt.locale(), use12H.value ? "hh:mm AP" : "hh:mm")
                opacity: 0.8
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                width: parent.width/4
                font.pixelSize: use12H.value ? parent.height/3.3 : parent.height/2.5
            }
            Label {
                id: title
                anchors.left: hour.right
                anchors.right: parent.right
                anchors.leftMargin: 20
                text: model.event.displayLabel
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: parent.height/3
            }
        }
    }

    property bool modelEmpty: agendaModel.count === 0

    Icon {
        id: emptyIndicator
        visible: modelEmpty
        width: Dims.w(27)
        height: width
        name: "ios-calendar-outline"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: weatherAvailable ? Dims.h(1) : -Dims.h(9)
        opacity: 0.8
    }

    Label {
        visible: modelEmpty
        anchors.topMargin: Dims.h(4)
        anchors.top: emptyIndicator.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        //% "No events today"
        text: qsTrId("id-no-events-today") + localeManager.changesObserver
        font.pixelSize: Dims.l(6)
        opacity: 0.8
    }
}
