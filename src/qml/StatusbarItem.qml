import QtQuick 2.0

Item {
    height: 48
    width: 48
    property alias source: icon.source

    Image {
        id: icon
        anchors.centerIn: parent
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (icon.source.toString().match("normal")) {
                icon.source = icon.source.toString().replace("normal","focused")
            } else {
                icon.source = icon.source.toString().replace("focused","normal")
            }
        }
    }
}
