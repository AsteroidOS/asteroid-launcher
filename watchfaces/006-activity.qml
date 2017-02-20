/*
 * Battery/Activity Watchface for AsteroidOS
 *
 * Inspired by the Google Fit watchface for Android Wear.
 *
 * The idea for this watchface is to display the value of step counter against
 * a daily goal using the pedometer sensor in bass. Until sensors are fully
 * supported in AsteroidOS we display the current battery charge level as a
 * proof of concept.
 *
 */

import QtQuick 2.1
import QtGraphicalEffects 1.0
import org.asteroid.controls 1.0
import org.freedesktop.contextkit 1.0

Item {
    id: rootitem
    property int currentValue: 0

    ProgressCircle {
        anchors.centerIn: parent
        height: rootitem.height
        width: rootitem.width
        color: "#3498db"
        backgroundColor: "#e5e6e8"
        animationEnabled: true
        value: rootitem.currentValue/100
    }

    Item {
        id: clock
        anchors.fill: parent

        Text {
            id: timeString
            anchors.centerIn: parent
            text:  Qt.formatDateTime(wallClock.time, "hh:mm")
            color: "white"
            font.pixelSize: parent.height*0.23
            font.family: "Roboto"
            font.weight: Font.Medium
        }
        Text {
            id: dateString
            anchors.top: timeString.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text:  Qt.formatDateTime(wallClock.time, "ddd MMM d")
            color: "white"
            font.pixelSize: parent.height*0.08
            font.family: "Roboto"
        }
        Text {
            anchors.top: dateString.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr(rootitem.currentValue+"%");
            color: "white"
            font.pixelSize: parent.height*0.08
            font.family: "Roboto"
        }
    }

    DropShadow {
        anchors.fill: clock
        source: clock
        radius: 7.0
        samples: 15
    }

    ContextProperty {
        id: batteryChargePercentage
        key: "Battery.ChargePercentage"
        onValueChanged: rootitem.currentValue = value
    }
}
