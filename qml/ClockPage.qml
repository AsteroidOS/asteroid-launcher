import QtQuick 2.1

Item {
    id: rootitem
    width: parent.width
    height: parent.height

    Text {
        id: timeDisplay

        font.pixelSize: 80
        font.weight: Font.Light
        lineHeight: 0.85
        color: "white"
        horizontalAlignment: Text.AlignHCenter

        anchors {
            verticalCenter: parent.verticalCenter
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
            top: timeDisplay.bottom
            left: parent.left
            right: parent.right
        }

        text: Qt.formatDateTime(wallClock.time, "<b>ddd.</b> d MMM.")
    }
}
