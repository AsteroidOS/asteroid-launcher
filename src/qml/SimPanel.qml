/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
** All rights reserved.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the author nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.1
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import MeeGo.QOfono 0.2
import QtQuick.Layouts 1.0

Component {
    CommonPanel {
        id: simpanel
        property bool needsPin: simManager.pinRequired === OfonoSimManager.SimPin ||
                                 simManager.pinRequired === OfonoSimManager.SimPuk
        onNeedsPinChanged: {
            if (needsPin === false) {
                panel_loader.visible = false
            }
        }

        Component.onCompleted: {
            simManager.modemPath = manager.modems
        }

        OfonoManager {
            id: manager
        }

        OfonoSimManager {
            id: simManager
        }

        ColumnLayout {
            visible: needsPin
            anchors.fill: simpanel
            spacing: 0
            RowLayout {
                spacing: 16
                TextField {
                    id: pinquery
                    width: 140
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.preferredHeight: 20
                }
                Button {
                    id: pinenter
                    text: "OK"
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.preferredHeight: 40
                    onClicked: {
                        simManager.enterPin(OfonoSimManager.SimPin, pinquery.text)
                        pinquery.text = ""
                    }
                }
                Button {
                    id: clearpin
                    text: "Clear"
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.preferredHeight: 40
                    onClicked: {
                        pinquery.text = ""
                    }
                }
            }
            GridLayout {
                columnSpacing: 10
                rowSpacing: 10
                columns: 3
                NumButton {
                    text: "1"
                }
                NumButton {
                    text: "2"
                }
                NumButton {
                    text: "3"
                }
                NumButton {
                    text: "4"
                }
                NumButton {
                    text: "5"
                }
                NumButton {
                    text: "6"
                }
                NumButton {
                    text: "7"
                }
                NumButton {
                    text: "8"
                }
                NumButton {
                    text: "9"
                }
                NumButton {
                    Layout.columnSpan: 3
                    text: "0"
                }
            }
        }
        Label {
            visible: !needsPin
            text: "No pin required!"
            font.pointSize: 16
        }
    }
}
