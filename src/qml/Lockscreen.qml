import QtQuick 2.0

Image {
    id: lockScreen
    source: "images/graphics-wallpaper-home.jpg"
    visible: LipstickSettings.lockscreenVisible

    LockscreenClock {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }
}

