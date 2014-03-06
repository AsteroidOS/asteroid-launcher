
import QtQuick 2.0

Rectangle {
    id: lockscreenClock
    height: (timeDisplay.height + dateDisplay.height) * 1.5

    gradient: Gradient {
        GradientStop { position: 0.0; color: '#b0000000' }
        GradientStop { position: 1.0; color: '#00000000' }
    }

    Column {
        id: clockColumn

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
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

            text: Qt.formatDateTime(wallClock.time, "<b>dddd</b>, d MMMM yyyy")
        }
    }
}

