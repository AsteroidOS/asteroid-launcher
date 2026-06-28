// Plays a sound once on a short-lived SoundEffect that is destroyed when
// playback ends, so the audio sink can suspend at idle. Drop-in for SoundEffect.

import QtQuick
import QtMultimedia

QtObject {
    id: root

    property url source
    property real volume: 1.0

    property Component effect: Component {
        SoundEffect {
            source: root.source
            volume: root.volume

            property bool started: false

            // The sample loads asynchronously; only play once it is ready, and
            // only once. Then tear the object down when playback finishes.
            function playWhenReady() {
                if (!started && status === SoundEffect.Ready) {
                    started = true
                    play()
                }
            }
            onStatusChanged: {
                playWhenReady()
                // If the sample can't be loaded it will never play or finish,
                // so destroy it here to avoid leaking an object per call.
                if (status === SoundEffect.Error)
                    destroy()
            }
            Component.onCompleted: playWhenReady()
            onPlayingChanged: if (started && !playing) destroy()
        }
    }

    function play() {
        effect.createObject(root)
    }
}
