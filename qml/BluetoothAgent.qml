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

import QtQuick 2.0
import org.asteroid.controls 1.0

Item {
    id: btAgent

    width: initialSize.width
    height: initialSize.height

    Image {
        anchors.fill: parent
        source: "qrc:/images/diskBackground.svg"
        sourceSize.width: width
        sourceSize.height: height
    }

    Icon {
        id: icon
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -parent.height*0.2
        width: parent.width*0.2
        height: width
        color: "#666666"
        name: "ios-bluetooth"
    }

    Text {
        id: summary
        anchors.top: icon.bottom
        height: text == "" ? 0 : undefined
        width: parent.width*0.7
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: parent.height*0.03
        color: "#666666"
        font.pixelSize: parent.height*0.05
        clip: true
        elide: Text.ElideRight
        text: "Confirm:"
    }

    Text {
        id: body
        anchors.top: summary.bottom
        width: parent.width/2
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#666666"
        font.pixelSize: parent.height*0.05
        font.bold: true
        clip: true
        maximumLineCount: 1
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        text: agent.passkey
    }

    IconButton {
        width: parent.height*0.2
        height: width
        iconColor: "#666666"
        pressedIconColor: "#222222"
        iconName: "ios-close-circle-outline"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -parent.width*0.12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height*0.21
        onClicked: {
            agent.userCancels()
            agent.windowVisible = false
        }
    }

    IconButton {
        width: parent.height*0.2
        height: width
        iconColor: "#666666"
        pressedIconColor: "#222222"
        iconName: "ios-checkmark-circle-outline"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: parent.width*0.12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height*0.21
        onClicked: {
            agent.userAccepts()
            agent.windowVisible = false
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }
}
