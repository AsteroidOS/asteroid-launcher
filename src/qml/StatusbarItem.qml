import QtQuick 2.0

Item {
    height: 48
    width: 48
    property alias source: icon.source
    property string panel_source
    property Component panel
    Image {
        id: icon
        anchors.centerIn: parent
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (panel_source !== "" && !panel) {
                panel_loader.source = panel_source
                panel_loader.visible = !panel_loader.visible
            }
            if (panel && panel_source === "") {
                panel_loader.sourceComponent = panel
                panel_loader.visible = !panel_loader.visible
            }

            if (icon.source.toString().match("normal")) {
                icon.source = icon.source.toString().replace("normal","focused")
            } else {
                icon.source = icon.source.toString().replace("focused","normal")
            }
        }
    }
}
