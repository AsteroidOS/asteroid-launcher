import QtQuick 2.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import org.nemomobile.lipstick 0.1

Item {
    id: wrapper
    property alias source: iconImage.source
    property alias iconCaption: iconText.text

    GridView {
        id: folderLoader
        anchors.top: parent.bottom
        width: appsListView.width
        height: childrenRect.height
        cellWidth: 115
        cellHeight: cellWidth + 30
        Rectangle {
            anchors.fill: parent
            opacity: 0.75
            color: "white"
        }

        delegate: MouseArea {
            width: appsListView.cellWidth
            height: appsListView.cellHeight
            Image {
                id: iconimage
                source: model.object.iconId == "" ? ":/images/icons/apps.png" : (model.object.iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + model.object.iconId
            }
            Text {
                id: icontext
                // elide only works if an explicit width is set
                width: parent.width
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 18
                color: 'white'
                anchors {
                    left: parent.left
                    right: parent.right
                    top: iconimage.bottom
                    topMargin: 5
                }
            }
            onClicked: {
                model.object.launchApplication()
            }
        }
    }

    // Application icon for the launcher
    MouseArea {
        id: launcherItem
        width: wrapper.width
        height: wrapper.height
        transformOrigin: Item.Center

        onClicked: {
            // TODO: disallow if close mode enabled
            if (model.object.type !== LauncherModel.Folder) {
                var winId = switcher.switchModel.getWindowIdForTitle(model.object.title)
                console.log("Window id found: " + winId)
                if (winId == 0)
                    model.object.launchApplication()
                else
                    Lipstick.compositor.windowToFront(winId)
            } else {
                if (!folderLoader.visible) {
                    folderLoader.visible = true
                    folderLoader.model = model.object
                } else {
                    folderLoader.visible = false
                }
            }
        }

        onPressAndHold: {
            // Show a similar cross as AppSwitcher
        }

        Image {
            id: iconImage
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 8
            }
            width: wrapper.width* 0.8
            height: width
            asynchronous: true

            Spinner {
                id: spinner
                anchors.centerIn: parent
                enabled: (model.object.type === LauncherModel.Application) ? model.object.isLaunching : false
            }
        }

        // Caption for the icon
        Text {
            id: iconText
            // elide only works if an explicit width is set
            width: parent.width
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 23
            color: 'white'
            anchors {
                left: parent.left
                right: parent.right
                top: iconImage.bottom
                topMargin: 5
            }
        }
    }
}
