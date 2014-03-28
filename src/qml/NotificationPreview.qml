
// This file is part of colorful-home, a nice user experience for touchscreens.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Copyright (C) 2012 Jolla Ltd.
// Contact: Vesa Halttunen <vesa.halttunen@jollamobile.com>

import QtQuick 2.0
//import org.freedesktop.contextkit 1.0
import org.nemomobile.lipstick 0.1

Item {
    id: notificationWindow
    property alias summary: summary.text
    property alias body: body.text
    property alias icon: icon.source
    width: initialSize.width
    height: initialSize.height

/*
 TODO
    ContextProperty {
        id: orientationAngleContextProperty
        key: "/Screen/CurrentWindow/OrientationAngle"
    }
*/

    QtObject {
        id: orientationAngleContextProperty
        property int value: 0
    }

    MouseArea {
        id: notificationArea
        property bool isPortrait: (orientationAngleContextProperty.value == 90 || orientationAngleContextProperty.value == 270)
        property int notificationHeight: 102
        property int notificationMargin: 14
        property int notificationIconSize: 60
        anchors.top: parent.top
        anchors.left: parent.left
        width: isPortrait ? notificationWindow.height : notificationWindow.width
        height: notificationArea.notificationHeight
        transform: Rotation {
            origin.x: { switch(orientationAngleContextProperty.value) {
                      case 270:
                          return notificationWindow.height / 2
                      case 180:
                      case 90:
                          return notificationWindow.width / 2
                      default:
                          return 0
                      } }
            origin.y: { switch(orientationAngleContextProperty.value) {
                case 270:
                case 180:
                    return notificationWindow.height / 2
                case 90:
                    return notificationWindow.width / 2
                default:
                    return 0
                } }
            angle: (orientationAngleContextProperty.value === undefined || orientationAngleContextProperty.value == 0) ? 0 : -360 + orientationAngleContextProperty.value
        }

        onClicked: if (notificationPreviewPresenter.notification != null) notificationPreviewPresenter.notification.actionInvoked("default")

        Rectangle {
            id: notificationPreview
            anchors {
                fill: parent
                margins: 10
            }
            color: "black"
            radius: 5
            border {
                color: "gray"
                width: 2
            }

            opacity: 0

            states: [
                State {
                    name: "show"
                    PropertyChanges {
                        target: notificationPreview
                        opacity: 1
                    }
                    StateChangeScript {
                        name: "notificationShown"
                        script: {
                            var topLeft = notificationPreview.mapToItem(notificationWindow, 0, 0)
                            var bottomRight = notificationPreview.mapToItem(notificationWindow, notificationPreview.width, notificationPreview.height)
                            notificationPreviewPresenter.setNotificationPreviewRect(topLeft.x, topLeft.y, bottomRight.x, bottomRight.y)
                            notificationTimer.start()
                        }
                    }
                },
                State {
                    name: "hide"
                    PropertyChanges {
                        target: notificationPreview
                        opacity: 0
                    }
                    StateChangeScript {
                        name: "notificationHidden"
                        script: {
                            notificationTimer.stop()
                            notificationPreviewPresenter.showNextNotification()
                        }
                    }
                }
            ]

            transitions: [
                Transition {
                    to: "show"
                    SequentialAnimation {
                        NumberAnimation { property: "opacity"; duration: 200 }
                        ScriptAction { scriptName: "notificationShown" }
                    }
                },
                Transition {
                    to: "hide"
                    SequentialAnimation {
                        NumberAnimation { property: "opacity"; duration: 200 }
                        ScriptAction { scriptName: "notificationHidden" }
                    }
                }
            ]

            Timer {
                id: notificationTimer
                interval: 3000
                repeat: false
                onTriggered: notificationPreview.state = "hide"
            }

            Image {
                id: icon
                anchors {
                    top: parent.top
                    left: parent.left
                    topMargin: notificationArea.notificationMargin - 3
                    leftMargin: notificationArea.notificationMargin
                }
                width: notificationArea.notificationIconSize
                height: width
                source: {
                    var icon = ""
                    if (notificationPreviewPresenter.notification != null) {
                        icon = notificationPreviewPresenter.notification.previewIcon ? notificationPreviewPresenter.notification.previewIcon : notificationPreviewPresenter.notification.icon
                        if (icon) {
                            icon = ((icon.indexOf("/") == 0 ? "file://" : "image://theme/") + icon)
                        }
                    }
                    icon
                }
            }

            Text {
                id: summary
                anchors {
                    top: parent.top
                    left: icon.right
                    right: parent.right
                    topMargin: notificationArea.notificationMargin
                    leftMargin: notificationArea.notificationMargin + 26
                    rightMargin: notificationArea.notificationMargin
                }
                font {
                    pixelSize: 22
                }
                text: notificationPreviewPresenter.notification != null ? notificationPreviewPresenter.notification.previewSummary : ""
                color: "white"
                clip: true
                elide: Text.ElideRight
            }

            Text {
                id: body
                anchors {
                    top: summary.bottom
                    left: summary.left
                    right: summary.right
                }
                font {
                    pixelSize: 22
                }
                text: notificationPreviewPresenter.notification != null ? notificationPreviewPresenter.notification.previewBody : ""
                color: "white"
                clip: true
                elide: Text.ElideRight
            }

            Connections {
                target: notificationPreviewPresenter;
                onNotificationChanged: notificationPreview.state = (notificationPreviewPresenter.notification != null) ? "show" : "hide"
            }
        }
    }
}
