import QtQuick 2.0
import QtQuick.Window 2.0
import org.nemomobile.lipstick 0.1

Rectangle {
    id: shutdownWindow
    width: Screen.width
    height: Screen.height
    color: "black"
    property bool shouldVisible
    opacity: shutdownScreen.windowVisible

    Image {
        anchors.centerIn: parent
        source: shutdownMode ? "" : "image://theme/graphic-shutdown-logo"
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 500
            onRunningChanged: if (!running && shutdownWindow.opacity == 0) shutdownScreen.windowVisible = false
        }
    }
}
