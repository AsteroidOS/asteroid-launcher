/*
 * Copyright (C) 2015 Florent Revest <revestflo@gmail.com>
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
import org.asteroid.controls 1.0

MouseArea {
    id: ma

    width: parent.width
    height: width

    property alias icon: ic.name

    // checkable defaults false so non-toggle buttons render at full opacity
    // without the caller needing to force a workaround state
    property bool checkable: false
    property bool checked: false

    property bool rangeBased: false
    property int rangeMin: 0
    property int rangeMax: 100
    property int rangeStepSize: 10
    property int rangeValue: 0

    pressAndHoldInterval: 300

    // -- Scrub interaction --
    // scrubWidth must be set by the caller to the available drag distance
    // (typically rootitem.width) so the full range maps across the panel.
    property bool scrubbing: false
    property int scrubWidth: 0
    property int startScrubX: 0
    property int startValue: 0

    // wasScrubbing is a backup guard for the case where onClicked does fire
    // after a short drag. For long drags Qt may not fire onClicked at all,
    // in which case scrubEventGuard on rootitem swallows the stray event.
    property bool wasScrubbing: false

    // Clear wasScrubbing at the start of a new press so the next full
    // click cycle works normally after a long drag that skipped onClicked
    onPressed: {
        if (wasScrubbing) wasScrubbing = false
    }
    
    onPressAndHold: {
        if (!rangeBased) return
            scrubbing = true
            wasScrubbing = true
            preventStealing = true
            startScrubX = mouseX
            startValue = rangeValue
            updateValue(mapToItem(rootitem, mouseX, 0).x)
    }

    onPositionChanged: {
        // Before hold is confirmed, preventStealing is false so the parent
        // ListView steals horizontal swipes naturally. Once scrubbing is
        // active, all position events are ours.
        if (!scrubbing) return
        updateValue(mapToItem(rootitem, mouseX, 0).x)
    }

    // onReleased is the unconditional cleanup — clears scrub state regardless
    // of which path activated it. wasScrubbing intentionally NOT cleared here
    // since onClicked fires after onReleased and needs to read it.
    onReleased: {
        scrubbing = false
        preventStealing = false
    }

    onCanceled: {
        scrubbing = false
        wasScrubbing = false
        preventStealing = false
    }

    // Snap-to-position with fat-finger margins: maps absolute panel x to the
    // value range. The 0.15 margin on each side matches scrubRangeWidth in
    // QuickPanel so the visual bar boundaries and finger position correspond.
    function updateValue(mx) {
        var margin = scrubWidth * 0.15
        var f = Math.max(0, Math.min(1, (mx - margin) / Math.max(1, scrubWidth - 2 * margin)))
        var newVal = rangeMin + f * (rangeMax - rangeMin)
        rangeValue = Math.max(rangeMin, Math.min(rangeMax, Math.round(newVal / rangeStepSize) * rangeStepSize))
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "#222222"
        opacity: ma.pressed ? 0.6 : ma.checked ? 0.75 : (ma.checkable ? 0.2 : 1)
    }

    Icon {
        id: ic
        width: parent.width * 0.5
        height: width
        anchors.centerIn: parent
        color: ma.pressed ? "lightgrey" : "white"
        opacity: ma.pressed ? 0.5 : ma.checked ? 1 : (ma.checkable ? 0.3 : 1)
    }
}
