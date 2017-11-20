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
import org.nemomobile.lipstick 0.1

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
        anchors.verticalCenterOffset: -Dims.h(20)
        width: Dims.w(20)
        height: width
        color: "#666666"
        name: "ios-bluetooth"
    }

    Item {
        id: text
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: icon.bottom
        anchors.topMargin: Dims.h(3)
        Label {
            id: summary
            anchors.top: parent.top
            width: Dims.w(70)
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#666666"
            font.pixelSize: Dims.h(5)
            clip: true
            elide: Text.ElideRight
        }

        Label {
            id: body
            anchors.top: summary.bottom
            width: Dims.w(70)
            height: Dims.h(10)
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            color: "#666666"
            font.bold: true
            clip: true
            maximumLineCount: 1
            elide: Text.ElideRight
            wrapMode: Text.Wrap
        }
    }

    TextField {
        id: inputField
        inputMethodHints: Qt.ImhDigitsOnly
        anchors.top: text.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: Dims.w(60)
    }

    IconButton {
        id: cancelButton
        iconColor: "#666666"
        iconName: "ios-close-circle-outline"
        edge: undefinedEdge
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -Dims.w(12)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Dims.h(21)
        onClicked: agent.userCancels()
    }

    IconButton {
        id: confirmButton
        iconColor: "#666666"
        iconName: "ios-checkmark-circle-outline"
        edge: undefinedEdge
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: Dims.w(12)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Dims.h(21)
        onClicked: {
            if(agent.state == BluetoothAgent.ReqPinCode)
                agent.pinCode = Number(inputField.text)
            if(agent.state == BluetoothAgent.ReqPasskey)
                agent.passkey = inputField.text
            agent.userAccepts()
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    HandWritingKeyboard {
        anchors.fill: parent
    }

    Connections {
        target: agent
        onStateChanged: {
            switch(agent.state) {
                case BluetoothAgent.AuthService:
                    //% "Authorize:"
                    summary.text = qsTrId("id-btagent-authorize")
                    body.text = agent.pinCode
                    text.visible = true
                    inputField.text = ""
                    inputField.previewText = ""
                    inputField.visible = false
                    cancelButton.visible = true
                    confirmButton.visible = true
                    break;

                case BluetoothAgent.ReqAuthorization:
                    //% "Authorize:"
                    summary.text = qsTrId("id-btagent-authorize")
                    body.text = ""
                    text.visible = true
                    inputField.text = ""
                    inputField.previewText = ""
                    inputField.visible = false
                    cancelButton.visible = true
                    confirmButton.visible = true
                    break;

                case BluetoothAgent.ReqConfirmation:
                    //% "Confirm:"
                    summary.text = qsTrId("id-btagent-confirm")
                    body.text = agent.passkey
                    text.visible = true
                    inputField.text = ""
                    inputField.previewText = ""
                    inputField.visible = false
                    cancelButton.visible = true
                    confirmButton.visible = true
                    break;

                case BluetoothAgent.DispPasskey:
                    //% "Pass Key:"
                    summary.text = qsTrId("id-btagent-passkey")
                    body.text = agent.passkey
                    text.visible = true
                    inputField.text = ""
                    inputField.previewText = ""
                    inputField.visible = false
                    cancelButton.visible = true
                    confirmButton.visible = true
                    break;

                case BluetoothAgent.ReqPasskey:
                    summary.text = ""
                    body.text = ""
                    text.visible = false
                    inputField.text = ""
                    //% "Enter Key"
                    inputField.previewText = qsTrId("id-btagent-enterkey")
                    inputField.visible = true
                    cancelButton.visible = true
                    confirmButton.visible = true
                    break;

                case BluetoothAgent.DispPinCode:
                    //% "PIN Code:"
                    summary.text = qsTrId("id-btagent-pincode")
                    body.text = agent.pinCode
                    text.visible = true
                    inputField.text = ""
                    inputField.previewText = ""
                    inputField.visible = false
                    cancelButton.visible = true
                    confirmButton.visible = true
                    break;

                case BluetoothAgent.ReqPinCode:
                    //% "PIN Code:"
                    summary.text = qsTrId("id-btagent-pincode")
                    body.text = ""
                    text.visible = false
                    inputField.text = ""
                    //% "Enter PIN Code"
                    inputField.previewText = qsTrId("id-btagent-enter-pincode")
                    inputField.visible = true
                    cancelButton.visible = true
                    confirmButton.visible = true
                    break;

                case BluetoothAgent.Idle:
                default:
                    summary.text = ""
                    body.text = ""
                    text.visible = false
                    inputField.text = ""
                    inputField.previewText = ""
                    inputField.visible = false
                    cancelButton.visible = false
                    confirmButton.visible = false
                    agent.windowVisible = false
                    break;
            }
        }
    }
}
