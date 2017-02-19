/*
 * Battery/Activity Watchface for AsteroidOS
 *
 * Inspired by the Google Fit watchface for Android Wear.
 *
 * This code was adopted from: http://stackoverflow.com/a/22903361 by Charles
 * and ported to AsteroidOS by Andrew E. Bruno
 *
 * The idea for this watchface is to display the value of step counter against
 * a daily goal using the pedometer sensor in bass. Until sensors are fully
 * supported in AsteroidOS we display the current battery charge level as a
 * proof of concept.
 *
 */

import QtQuick 2.1
import QtGraphicalEffects 1.0
import QtQml 2.2
import org.freedesktop.contextkit 1.0

Item {
    id: rootitem

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        property color fontColor: "#ffffff"
        property color primaryColor: "#000000"
        property color secondaryColor: "#c51c19"
        property date currentTime: wallClock.time

        property real centerWidth: width / 2
        property real centerHeight: height / 2
        property real radius: Math.min(canvas.width-25, canvas.height-25) / 2

        property real minimumValue: 0
        property real maximumValue: 100
        property int currentValue: 0

        // this is the angle that splits the circle in two arcs
        // first arc is drawn from 0 radians to angle radians
        // second arc is angle radians to 2*PI radians
        property real angle: (currentValue - minimumValue) / (maximumValue - minimumValue) * 2 * Math.PI

        // we want both circle to start / end at 12 o'clock
        // without this offset we would start / end at 9 o'clock
        property real angleOffset: -Math.PI / 2

        signal clicked()
        onCurrentValueChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            ctx.save();

            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // fills the mouse area when pressed
            // the fill color is a lighter version of the
            // secondary color

            if (mouseArea.pressed) {
                ctx.beginPath();
                ctx.lineWidth = 20;
                ctx.fillStyle = Qt.lighter(canvas.secondaryColor, 0.95);
                ctx.arc(canvas.centerWidth,
                        canvas.centerHeight,
                        canvas.radius,
                        0,
                        2*Math.PI);
                ctx.fill();
            }

            // First, thinner arc
            // From angle to 2*PI

            ctx.beginPath();
            ctx.lineWidth = 20;
            ctx.strokeStyle = primaryColor;
            ctx.arc(canvas.centerWidth,
                    canvas.centerHeight,
                    canvas.radius,
                    angleOffset + canvas.angle,
                    angleOffset + 2*Math.PI);
            ctx.stroke();


            // Second, thicker arc
            // From 0 to angle

            ctx.beginPath();
            ctx.lineWidth = 30;
            ctx.strokeStyle = canvas.secondaryColor;
            ctx.arc(canvas.centerWidth,
                    canvas.centerHeight,
                    canvas.radius,
                    canvas.angleOffset,
                    canvas.angleOffset + canvas.angle);
            ctx.stroke();

            ctx.restore();
        }

        Text {
            id: timeString
            anchors.centerIn: parent
            text:  Qt.formatDateTime(canvas.currentTime, "hh:mm")
            color: canvas.fontColor
            font.pixelSize: parent.height*0.23
            font.family: "Roboto"
            font.weight: Font.Medium
        }
        Text {
            id: dateString
            anchors.top: timeString.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text:  Qt.formatDateTime(canvas.currentTime, "ddd MMM d")
            color: canvas.fontColor
            font.pixelSize: parent.height*0.08
            font.family: "Roboto"
        }
        Text {
            anchors.top: dateString.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr(canvas.currentValue+"%");
            color: canvas.fontColor
            font.pixelSize: parent.height*0.08
            font.family: "Roboto"
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            onClicked: canvas.clicked()
            onPressedChanged: canvas.requestPaint()
        }
    }

    ContextProperty {
        id: batteryChargePercentage
        key: "Battery.ChargePercentage"
        onValueChanged: canvas.currentValue = value
    }
}
