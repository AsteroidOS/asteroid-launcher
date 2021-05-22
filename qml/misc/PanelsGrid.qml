/*
 * Copyright (C) 2017 Florent Revest <revestflo@gmail.com>
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
import org.asteroid.launcher 1.0

GestureFilterArea {
    id: panelsGrid

    property real normalizedHorOffset: 0
    property real normalizedVerOffset: 0

    /* Item that will move according to the user's needs */
    Item {
        id: content
        onXChanged: if(normalizedVerOffset == 0) normalizedHorOffset = Math.min(Math.max(-(content.x/panelWidth),  -1), 1)
        onYChanged: if(normalizedHorOffset == 0) normalizedVerOffset = Math.min(Math.max(-(content.y/panelHeight), -1), 1)
    }

    /* Panels handling */

    property var panels: {'dummyVal': undefined} /* Map of panels, indexed by position */
    property alias panelWidth:  panelsGrid.width
    property alias panelHeight: panelsGrid.height

    function addPanel(horizontalPos, verticalPos, component) {
        if (component.status === Component.Ready) {
            var panel = component.createObject(content)

            panel.x = panelWidth*horizontalPos
            panel.y = panelHeight*verticalPos
            panel.width = panelWidth
            panel.height = panelHeight
            if(panel.panelsGrid !== undefined)
                panel.panelsGrid = panelsGrid
            panels[horizontalPos + "x" + verticalPos] = panel
            return panel
        }
    }

    function removePanel(horizontalPos, verticalPos) {
        var panel = panels[horizontalPos + "x" + verticalPos]
        if(panel !== undefined)
            panel.destroy()
        panels[horizontalPos + "x" + verticalPos] = undefined
    }

    function movePanel(originHorizontalPos, originVerticalPos, destHorizontalPos, destVerticalPos) {
        var panel = panels[originHorizontalPos + "x" + originVerticalPos]
        if(panel !== undefined) {
            panels[destHorizontalPos + "x" + destVerticalPos] = panel
            panel.x = panelWidth*destHorizontalPos
            panel.y = panelHeight*destVerticalPos
            panels[originHorizontalPos + "x" + originVerticalPos] = undefined
        }
    }

    function moveTo(posX, posY) {
        content.x = -panelWidth*posX
        content.y = -panelHeight*posY
        currentHorizontalPos = posX
        currentVerticalPos = posY
    }

    onWidthChanged: {
        for(var name in panels) {
            if(panels[name] !== undefined) {
                var horizontalPos = name.split('x')[0]
                panels[name].x = panelWidth*horizontalPos
                panels[name].width = panelWidth
            }
        }
    }

    onHeightChanged: {
        for(var name in panels) {
            if(panels[name] !== undefined) {
                var verticalPos = name.split('x')[1]
                panels[name].y = panelHeight*verticalPos
                panels[name].height = panelHeight
            }
        }
    }

    /* Possible directions handling */
    property int currentVerticalPos:   0
    property int currentHorizontalPos: 0

    function changeAllowedDirections() {
        var currentPanel = panels[currentHorizontalPos + "x" + currentVerticalPos]
        if(currentPanel === undefined) return

        var currentPanelName = currentHorizontalPos + "x" + currentVerticalPos
        var topPanelName =     currentHorizontalPos + "x" + (currentVerticalPos-1)
        var bottomPanelName =  currentHorizontalPos + "x" + (currentVerticalPos+1)
        var leftPanelName =    (currentHorizontalPos-1) + "x" + currentVerticalPos
        var rightPanelName =   (currentHorizontalPos+1) + "x" + currentVerticalPos

        toTopAllowed    = false
        toBottomAllowed = false
        toRightAllowed  = false
        toLeftAllowed   = false

        for(var name in panels) {
            if(panels[name] !== undefined) {
                if(name.localeCompare(topPanelName)===0 && currentPanel.forbidTop !== true)            toBottomAllowed = true
                else if(name.localeCompare(bottomPanelName)===0 && currentPanel.forbidBottom !== true) toTopAllowed = true
                else if(name.localeCompare(leftPanelName)===0 && currentPanel.forbidLeft !== true)     toRightAllowed = true
                else if(name.localeCompare(rightPanelName)===0 && currentPanel.forbidRight !== true)   toLeftAllowed = true

                if (name.localeCompare(currentPanelName)===0) panels[name].visible = true
                else panels[name].visible = false
            }
        }
    }

    onCurrentVerticalPosChanged:   changeAllowedDirections()
    onCurrentHorizontalPosChanged: changeAllowedDirections()

    /* Swipe handling */

    property alias contentX: content.x
    property alias contentY: content.y

    onContentXChanged: {
        panels[(currentHorizontalPos+1) + "x" + currentVerticalPos].visible = true
        panels[(currentHorizontalPos-1) + "x" + currentVerticalPos].visible = true
    }

    onContentYChanged: {
        panels[currentHorizontalPos + "x" + (currentVerticalPos-1)].visible = true
        panels[currentHorizontalPos + "x" + (currentVerticalPos+1)].visible = true
    }

    onSwipeMoved: {
        if(horizontal) {
            contentX = content.x + delta
            var currentPanelX = -currentHorizontalPos*panelWidth
            contentX = Math.min(contentX, currentPanelX + (toRightAllowed ? panelWidth  : 0))
            contentX = Math.max(contentX, currentPanelX + (toLeftAllowed  ? -panelWidth : 0))
        } else {
            contentY = content.y + delta
            var currentPanelY = -currentVerticalPos*panelHeight
            contentY = Math.min(contentY, currentPanelY + (toBottomAllowed ? panelHeight  : 0))
            contentY = Math.max(contentY, currentPanelY + (toTopAllowed    ? -panelHeight : 0))
        }
    }

    function animateIndicators() {
        rightIndicator.animateFar()
        leftIndicator.animateFar()
        topIndicator.animateFar()
        bottomIndicator.animateFar()
    }

    onSwipeReleased: {
        if(!tracing) {
            if(horizontal) {
                if(velocity>0 && toRightAllowed)
                    currentHorizontalPos--
                else if(velocity< 0 && toLeftAllowed)
                    currentHorizontalPos++

                contentAnim.property = "x"
                contentAnim.to = -panelWidth*currentHorizontalPos
                contentAnim.start()
            } else {
                if(velocity>0 && toBottomAllowed)
                    currentVerticalPos--
                else if(velocity< 0 && toTopAllowed)
                    currentVerticalPos++

                contentAnim.property = "y"
                contentAnim.to = -panelHeight*currentVerticalPos
                contentAnim.start()
            }
        }

        animateIndicators()
    }

    NumberAnimation {
        id: contentAnim
        target: content
        duration: 100
    }
}
