import QtQuick 2.0
import QtQuick.Window 2.0
import org.nemomobile.lipstick 0.1
import ".."

Rectangle {
    id: shutdownWindow
    width: parent.width
    height: parent.height
    color: "black"
    property bool shouldVisible
    opacity: shutdownScreen.windowVisible

    LauncherRotation {
        id: launcherRotation
        rotationParent: shutdownWindow.parent
    }

    Connections {
        target: shutdownScreen
        onWindowVisibleChanged: {
            if (shutdownScreen.windowVisible) {
                launcherRotation.rotateRotationParent(nativeOrientation)
            }
        }
    }

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
