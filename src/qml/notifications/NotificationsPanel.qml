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

import QtQuick
import org.nemomobile.lipstick
import org.asteroid.controls

Item {
    id: notifPanel

    property QtObject panelsGrid
    property QtObject firstNotifView: null
    property bool forbidTop: firstNotifView !== null ? firstNotifView.forbidTop : false
    property bool modelEmpty: notifModel.itemCount === 0

    onForbidTopChanged: panelsGrid.changeAllowedDirections()

    /*
     * Notifications occupy a horizontal strip to the left of the watchface.
     * The newest notification is "logical position" 0 and sits nearest the
     * watchface; older ones extend further left. A notification at position p
     * lives in two grid cells: its view at (colOf(p), 0) and its action panel
     * at (colOf(p), -1).
     *
     * Position 0 is special: its view is not a grid cell but `firstNotifView`,
     * a child overlaid on this panel (the grid's (-1, 0) cell), so that the
     * empty-state indicator below can share the same cell. Its action panel is
     * still an ordinary grid cell like every other.
     */
    function colOf(pos) { return -(pos + 1) }

    function makeGridView(pos, notif) {
        var view = panelsGrid.addPanel(colOf(pos), 0, notificationViewComp)
        view.visible = false
        view.notification = notif
        view.panelsGrid = panelsGrid
    }

    function makeActions(pos, notif) {
        var act = panelsGrid.addPanel(colOf(pos), -1, notificationActionsComp)
        act.visible = false
        act.notification = notif
        act.panelsGrid = panelsGrid
        act.notificationModel = notifModel
    }

    function makeFirstView(notif) {
        firstNotifView = notificationViewComp.createObject(notifPanel)
        firstNotifView.x = 0
        firstNotifView.y = 0
        firstNotifView.width = Qt.binding(function() { return notifPanel.width })
        firstNotifView.height = Qt.binding(function() { return notifPanel.height })
        firstNotifView.notification = notif
        firstNotifView.panelsGrid = panelsGrid
    }

    /* Relocate the notification at position `from` to position `to`, handling
     * the position-0 view (embedded firstNotifView) ↔ grid-cell transitions.
     * The action panel is always an ordinary grid cell. Callers move panels in
     * an order that never overwrites a still-occupied destination cell. */
    function movePosition(from, to) {
        panelsGrid.movePanel(colOf(from), -1, colOf(to), -1)

        if (from === 0) {
            // The embedded view becomes an ordinary grid cell.
            var notif = firstNotifView.notification
            firstNotifView.destroy()
            firstNotifView = null
            makeGridView(to, notif)
        } else if (to === 0) {
            // A grid-cell view becomes the embedded one.
            var rec = panelsGrid.cellAt(colOf(from), 0)
            if (rec !== undefined) {
                var n = rec.item.notification
                panelsGrid.removePanel(colOf(from), 0)
                makeFirstView(n)
            }
        } else {
            panelsGrid.movePanel(colOf(from), 0, colOf(to), 0)
        }
    }

    function destroyPosition(pos) {
        panelsGrid.removePanel(colOf(pos), -1)
        if (pos === 0) {
            if (firstNotifView !== null) { firstNotifView.destroy(); firstNotifView = null }
        } else {
            panelsGrid.removePanel(colOf(pos), 0)
        }
    }

    NotificationListModel {
        id: notifModel
        onItemAdded: {
            var index = notifModel.indexOf(item)

            // Shift everything from `index` outward one position to make room.
            // Outermost first so we never move into an occupied cell.
            for (var p = notifModel.itemCount - 2; p >= index; p--)
                movePosition(p, p + 1)

            makeActions(index, item)
            if (index === 0)
                makeFirstView(item)
            else
                makeGridView(index, item)

            panelsGrid.changeAllowedDirections()
        }

        onRowsRemoved: {
            var removed = last - first + 1
            var oldCount = notifModel.itemCount + removed

            for (var p = first; p <= last; p++)
                destroyPosition(p)

            // Close the gap: survivors above the removed block move inward by
            // `removed`. Innermost (lowest destination) first so we never move
            // into a cell that is still occupied.
            for (var p = last + 1; p < oldCount; p++)
                movePosition(p, p - removed)

            if (first === 0 && notifModel.itemCount > 0)
                panelsGrid.moveTo(-1, 0)
            else
                panelsGrid.moveTo(-first, 0)
        }
    }

    Component {
        id: notificationActionsComp
        NotificationActions {}
    }
    Component {
        id: notificationViewComp
        NotificationView    {}
    }

    Icon {
        id: emptyIndicator
        visible: modelEmpty
        width: Dims.w(27)
        height: width
        name: "ios-mail-outline"
        opacity: 0.8
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -Dims.h(9)
    }

    Label {
        visible: modelEmpty
        anchors.topMargin: Dims.h(4)
        anchors.top: emptyIndicator.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        //% "No notifications"
        text: qsTrId("id-no-notifications") + localeManager.changesObserver
        font.pixelSize: Dims.l(6)
        opacity: 0.8
    }
}

