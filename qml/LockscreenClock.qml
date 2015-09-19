
import QtQuick 2.0

Rectangle {
    id: lockscreenClock
    height: (timeDisplay.height + dateDisplay.height) * 1.5

    color: "transparent"

    Column {
        id: clockColumn

        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: timeDisplay

            font.pixelSize: 80
            font.weight: Font.Light
            lineHeight: 0.85
            color: "white"
            horizontalAlignment: Text.AlignHCenter

            anchors {
                left: parent.left
                right: parent.right
            }

            text: Qt.formatDateTime(wallClock.time, "hh:mm")
        }

        Text {
            id: dateDisplay

            font.pixelSize: 20
            color: "white"
            opacity: 0.8
            horizontalAlignment: Text.AlignHCenter

            anchors {
                left: parent.left
                right: parent.right
            }

            text: Qt.formatDateTime(wallClock.time, "<b>ddd.</b> d MMM.")
        }
    }
}

