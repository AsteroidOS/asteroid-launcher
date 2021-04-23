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
import Nemo.Time 1.0
import org.nemomobile.systemsettings 1.0
import Nemo.Configuration 1.0
import "desktop.js" as Desktop

FlatMesh {
    id: config
    anchors.fill: parent
    centerColor: "#222222"
    outerColor: "#000000"

    Component.onCompleted: firstRun.startFirstRun()

    ConfigurationValue {
        id: use12H
        key: "/org/asteroidos/settings/use-12h-format"
        defaultValue: false
    }

    state: "LANGUAGE"

    states: [
        State { name: "LANGUAGE" },
        State { name: "TIME" },
        State { name: "DATE" }
    ]

    LanguageModel { id: langSettings }
    Spinner {
        id: langLV
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        height: Dims.h(60)
        model: langSettings
        visible: config.state == "LANGUAGE"
        enabled: visible

        delegate: SpinnerDelegate { text: langSettings.languageName(index) }
        Component.onCompleted: {
            var i = langSettings.currentIndex;
            if(i != -1)
                langLV.positionViewAtIndex(i, ListView.SnapPosition)
        }
    }

    DateTimeSettings { id: dtSettings }
    WallClock { id: wallClock}
    Row {
        id: timeSelector
        anchors.top: title.bottom
        height: Dims.h(60)
        width: parent.width
        visible: config.state == "TIME"
        enabled: visible

        property int spinnerWidth: use12H.value ? width/3 : width/2

        CircularSpinner {
            id: hourLV
            height: parent.height
            width: parent.spinnerWidth
            model: use12H.value ? 12 : 24
            showSeparator: true
        }

        CircularSpinner {
            id: minuteLV
            height: parent.height
            width: parent.spinnerWidth
            model: 60
            showSeparator: use12H.value
        }

        Spinner {
            id: amPmLV
            height: parent.height
            width: parent.spinnerWidth
            model: 2
            delegate: SpinnerDelegate { text: index == 0 ? "AM" : "PM" }
        }

        Component.onCompleted: {
            var hour = wallClock.time.getHours();
            if(use12H.value) {
                amPmLV.currentIndex = hour / 12;
                hour = hour % 12;
            }
            hourLV.currentIndex = hour;
            minuteLV.currentIndex = wallClock.time.getMinutes();
        }
    }

    Row {
        id: dateSelector
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        height: Dims.h(60)
        visible: config.state == "DATE"
        enabled: visible

        CircularSpinner {
            id: dayLV
            height: parent.height
            width: parent.width/3
            model: 31
            showSeparator: true
            delegate: SpinnerDelegate { text: index+1 }
        }

        CircularSpinner {
            id: monthLV
            height: parent.height
            width: parent.width/3
            model: 12
            showSeparator: true
            delegate: SpinnerDelegate { text: Qt.locale().monthName(index, Locale.ShortFormat) + localeManager.changesObserver }
        }

        CircularSpinner {
            id: yearLV
            height: parent.height
            width: parent.width/3
            model: 100
            delegate: SpinnerDelegate { text: index+2000 }
        }

        Component.onCompleted: {
            var d = new Date();
            dayLV.currentIndex = d.getDate()-1;
            monthLV.currentIndex = d.getMonth();
            yearLV.currentIndex = d.getFullYear()-2000;
        }
    }

    PageHeader {
        id: title
        //% "Language"
        text: qsTrId("id-language-page") + localeManager.changesObserver
    }

    IconButton {
        id: nextButton
        iconName: "ios-arrow-dropright"
        anchors { 
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: Dims.iconButtonMargin
        }
        onClicked: {
            switch(config.state) {
                case "LANGUAGE":
                    var locale = langSettings.locale(langLV.currentIndex)
                    langSettings.setSystemLocale(locale, LanguageModel.UpdateWithoutReboot)
                    localeManager.selectLocale(locale)

                    //% "Time"
                    title.text = qsTrId("id-time-page") + localeManager.changesObserver

                    config.state = "TIME";
                    break;
                case "TIME":
                    var hour = hourLV.currentIndex;
                    if(use12H.value)
                        hour += amPmLV.currentIndex*12;
                    dtSettings.setTime(hour, minuteLV.currentIndex)

                    //% "Date"
                    title.text = qsTrId("id-date-page") + localeManager.changesObserver

                    config.state = "DATE";
                    break;
                case "DATE":
                    var date = new Date();
                    date.setDate(dayLV.currentIndex+1)
                    date.setMonth(monthLV.currentIndex)
                    date.setFullYear(yearLV.currentIndex+2000)
                    dtSettings.setDate(date)

                    config.destroy()
                    break;
                default:
                    console.log("FirstRunConfig: Unhandled state detected");
            }
        }
    }
}
