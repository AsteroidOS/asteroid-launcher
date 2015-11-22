import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0
import org.nemomobile.time 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.lipstick 0.1

Page {
    id: desktop
    property var switcher: null

    Component.onCompleted: {
        Lipstick.compositor.screenOrientation = nativeOrientation
        LipstickSettings.lockScreen(true)
    }

    WallClock {
        id: wallClock
        enabled: true
        updateFrequency: WallClock.Minute
    }

    Connections {
        target: lipstickSettings;
        onLockscreenVisibleChanged: {
            if(lipstickSettings.lockscreenVisible) {
                wallClock.enabled = true
            } else {
                wallClock.enabled = false
            }
        }
    }

    LauncherRotation { id: launcherRotation; rotationParent: desktop.parent }
    orientation: Lipstick.compositor.screenOrientation
    onParentChanged: launcherRotation.rotateRotationParent(nativeOrientation)

    Component { id: topPage;    QuickSettings { id: quickSet; width: desktop.width; height: desktop.height } }
    Component { id: leftPage;   AppSwitcher   { id: switcher; width: desktop.width; height: desktop.height; visibleInHome: x > -width && x < desktop.width; Component.onCompleted: { desktop.switcher = switcher }} }
    Component { id: centerPage; ClockPage     { id: clock;    width: desktop.width; height: desktop.height } }
    Component { id: rightPage;  FeedsPage     { id: feed;     width: desktop.width; height: desktop.height } }
    Component { id: bottomPage; AppLauncher   { id: launcher; width: desktop.width; height: desktop.height; switcher: desktop.switcher } }

    Component { id: centerRow; ListView { id: centerListView // The three columns of the center row
            model: 3
            orientation: ListView.Horizontal
            width: desktop.width; height: desktop.height;
            snapMode: ListView.SnapOneItem
            currentIndex: 1

            delegate: Loader {
                sourceComponent: {
                    switch (index)
                    {
                        case 0: return leftPage
                        case 1: return centerPage
                        case 2: return rightPage
                    }
                }
            }
            onContentXChanged: {
                verticalListView.interactive = centerListView.contentX == width // Only allows vertical flicking for the center item
                wallpaperBlur.radius = (centerListView.contentX > height*2/3 && centerListView.contentX < height*4/3)  ? 0 : 35
            }
        }
    }

    ListView { // three rows
        id: verticalListView
        model: 3
        orientation: ListView.Vertical
        anchors.fill: parent
        snapMode: ListView.SnapOneItem
        currentIndex: 1

        delegate:Loader {
            sourceComponent: {
                switch (index)
                {
                    case 0: return topPage
                    case 1: return centerRow
                    case 2: return bottomPage
                }
            }
        }
        onContentYChanged: wallpaperBlur.radius = (verticalListView.contentY > height*2/3 && verticalListView.contentY < height*4/3)  ? 0 : 35
    }

// Wallpaper
    ConfigurationValue {
        id: wallpaperSource
        key: "/desktop/asteroid/background_filename"
        defaultValue: "qrc:/qml/images/graphics-wallpaper-home.jpg"
    }

    Image {
        id: wallpaper
        source: wallpaperSource.value
        anchors.fill: parent
        z: -100
    }

    FastBlur {
        id: wallpaperBlur
        anchors.fill: wallpaper
        source: wallpaper
        z: -99
        Behavior on radius { PropertyAnimation { duration: 200 } }
    }
}
