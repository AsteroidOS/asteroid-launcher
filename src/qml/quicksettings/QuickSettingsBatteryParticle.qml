import QtQuick 2.9
import QtGraphicalEffects 1.15

Item {
    id: particleRoot
    width: maxSize
    height: maxSize

    property real maxSize: 10
    property real targetX: 0
    property int lifetime: 2000
    property bool isCharging: false

    // Destroy timer to handle particle cleanup
    Timer {
        id: destroyTimer
        interval: lifetime
        running: true
        repeat: false
        onTriggered: particleRoot.destroy()
    }

    Rectangle {
        id: diamond
        width: particleRoot.width * particleSize
        height: particleRoot.width * particleSize
        color: "#FFFFFF"
        anchors.centerIn: parent
        rotation: 45
        opacity: particleOpacity

        property real particleSize: 0.5
        property real particleOpacity: 0
    }

    ParallelAnimation {
        id: particleAnimation
        running: true

        // Position animation
        NumberAnimation {
            target: particleRoot
            property: "x"
            to: targetX
            duration: lifetime
            easing.type: Easing.InOutSine
        }

        // Size animation
        SequentialAnimation {
            NumberAnimation {
                target: diamond
                property: "particleSize"
                from: 0.4
                to: 1.0
                duration: lifetime / 2
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: diamond
                property: "particleSize"
                from: 1.0
                to: 0.4
                duration: lifetime / 2
                easing.type: Easing.InQuad
            }
        }

        // Opacity animation
        SequentialAnimation {
            NumberAnimation {
                target: diamond
                property: "particleOpacity"
                from: 0
                to: 0.4
                duration: lifetime / 2
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: diamond
                property: "particleOpacity"
                from: 0.4
                to: 0
                duration: lifetime / 2
                easing.type: Easing.InQuad
            }
        }
    }
}
