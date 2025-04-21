/*
 * Copyright (C) 2025 Timo Könnecke <github.com/eLtMosen>
 *
 * All rights reserved.
 *
 * You may use this file under the terms of BSD license as follows:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the author nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
import QtQuick 2.9
import QtGraphicalEffects 1.15
import org.asteroid.controls 1.0

Item {
    id: particleRoot
    width: maxSize
    height: maxSize

    property real maxSize: 10
    property real targetX: 0
    property int lifetime: 1200
    property bool isCharging: false
    property string design: "diamonds" // Set default design

    // Define design-specific properties
    property var designProperties: {
        "diamonds": { initialSize: 0.4, maxSize: 1.0, initialOpacity: 0, maxOpacity: 0.4 },
        "bubbles": { initialSize: 0.4, maxSize: 1.0, initialOpacity: 0, maxOpacity: 0.4 },
        "logos": { initialSize: 0.5, maxSize: 1.2, initialOpacity: 0, maxOpacity: 0.6 },
        "flashes": { initialSize: 0.6, maxSize: 1.4, initialOpacity: 0, maxOpacity: 0.7 }
    }

    // Get design properties with fallback
    function getDesignProp(propName) {
        return (designProperties[design] && designProperties[design][propName])
               ? designProperties[design][propName]
               : designProperties["diamonds"][propName];
    }

    // Destroy timer to handle particle cleanup
    Timer {
        id: destroyTimer
        interval: lifetime
        running: true
        repeat: false
        onTriggered: particleRoot.destroy()
    }

    // Diamond design
    Rectangle {
        id: diamond
        width: particleRoot.width * particleSize
        height: particleRoot.width * particleSize
        color: "#FFFFFF"
        anchors.centerIn: parent
        rotation: 45
        opacity: particleOpacity
        visible: particleRoot.design === "diamonds"

        property real particleSize: getDesignProp("initialSize")
        property real particleOpacity: getDesignProp("initialOpacity")
    }

    // Logo design
    Image {
        id: logo
        source: "qrc:/images/shutdown-logo.png"
        width: particleRoot.width * particleSize
        height: particleRoot.width * particleSize
        anchors.centerIn: parent
        opacity: particleOpacity
        visible: particleRoot.design === "logos"

        property real particleSize: getDesignProp("initialSize")
        property real particleOpacity: getDesignProp("initialOpacity")
    }

    // Bubble design
    Rectangle {
        id: bubble
        width: particleRoot.width * particleSize
        height: particleRoot.width * particleSize
        radius: width / 2
        color: "#FFFFFF"
        anchors.centerIn: parent
        opacity: particleOpacity
        visible: particleRoot.design === "bubbles"

        property real particleSize: getDesignProp("initialSize")
        property real particleOpacity: getDesignProp("initialOpacity")
    }

    // Flash design
    Icon {
        id: flash
        width: particleRoot.width * particleSize
        height: particleRoot.width * particleSize
        name: "ios-flash"
        anchors.centerIn: parent
        opacity: particleOpacity
        visible: particleRoot.design === "flashes"

        property real particleSize: getDesignProp("initialSize")
        property real particleOpacity: getDesignProp("initialOpacity")
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

        // Size animation - dynamically determine target based on current design
        SequentialAnimation {
            NumberAnimation {
                target: {
                    switch(particleRoot.design) {
                        case "diamonds": return diamond;
                        case "logos": return logo;
                        case "bubbles": return bubble;
                        case "flashes": return flash;
                        default: return diamond;
                    }
                }
                property: "particleSize"
                from: getDesignProp("initialSize")
                to: getDesignProp("maxSize")
                duration: lifetime / 2
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: {
                    switch(particleRoot.design) {
                        case "diamonds": return diamond;
                        case "logos": return logo;
                        case "bubbles": return bubble;
                        case "flashes": return flash;
                        default: return diamond;
                    }
                }
                property: "particleSize"
                from: getDesignProp("maxSize")
                to: getDesignProp("initialSize")
                duration: lifetime / 2
                easing.type: Easing.InQuad
            }
        }

        // Opacity animation - dynamically determine target based on current design
        SequentialAnimation {
            NumberAnimation {
                target: {
                    switch(particleRoot.design) {
                        case "diamonds": return diamond;
                        case "logos": return logo;
                        case "bubbles": return bubble;
                        case "flashes": return flash;
                        default: return diamond;
                    }
                }
                property: "particleOpacity"
                from: getDesignProp("initialOpacity")
                to: getDesignProp("maxOpacity")
                duration: lifetime / 2
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: {
                    switch(particleRoot.design) {
                        case "diamonds": return diamond;
                        case "logos": return logo;
                        case "bubbles": return bubble;
                        case "flashes": return flash;
                        default: return diamond;
                    }
                }
                property: "particleOpacity"
                from: getDesignProp("maxOpacity")
                to: getDesignProp("initialOpacity")
                duration: lifetime / 2
                easing.type: Easing.InQuad
            }
        }
    }
}
