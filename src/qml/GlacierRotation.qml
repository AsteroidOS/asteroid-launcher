/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
** All rights reserved.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the author nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.1
import QtQuick.Window 2.1
import org.nemomobile.lipstick 0.1

Item {

    property int _nativeRotation: Screen.angleBetween(nativeOrientation, Screen.primaryOrientation)
    property bool _nativeIsPortrait: ((_nativeRotation === 0) || (_nativeRotation === 180))

    property Item rotationParent
    property variant unrotatedItems: []

    function rotationDiff(a, b) {
        var r =_nativeRotation - rotationParent.rotation
        if (r < 360)
            r += 360
        return r
    }

    function rotateRotationParent(o) {
        rotateObject(rotationParent, o)
        for(var i = 0; i < unrotatedItems.length; i++) {
            rotateObjectToAngle(unrotatedItems[i], rotationDiff(_nativeRotation, rotationParent.rotation))
        }
    }

    function rotateObject(obj, o) {
        var r = Screen.angleBetween(o, Screen.primaryOrientation)
        if (obj.rotation !== r)
            rotateObjectToAngle(obj, r)
    }

    function rotateObjectToAngle(obj, r) {
        obj.width = Screen.width; obj.height = Screen.height; obj.x = 0; obj.y = 0
        obj.rotation = r
        var res = obj.mapToItem((obj === rotationParent) ?  rotationParent.parent : rotationParent, 0, 0, obj.width, obj.height)
        if (obj !== rotationParent) {
            if (_nativeIsPortrait) {
                var i = res.x
                res.x = res.y
                res.y = i
            }
            var res2 = rotationParent.mapToItem(rotationParent.parent, 0, 0, res.width, res.height)
            res.width = res2.width; res.height = res2.height
        }
        obj.x = res.x; obj.y = res.y; obj.width = res.width; obj.height = res.height
    }
}
