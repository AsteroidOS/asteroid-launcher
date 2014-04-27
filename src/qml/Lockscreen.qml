import QtQuick 2.0

Image {
    id: lockScreen
    source: "images/graphics-wallpaper-home.jpg"

    /**
     * openingState should be a value between 0 and 1, where 0 means
     * the lockscreen is "down" (obscures the view) and 1 means the
     * lockscreen is "up" (not visible).
     **/
    visible: LipstickSettings.lockscreenVisible

    function snapPosition() {
    }

    Connections {
        target: LipstickSettings
        onLockscreenVisibleChanged: snapPosition()
    }

    LockscreenClock {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }
}

