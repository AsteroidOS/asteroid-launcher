import QtQuick 2.0
import org.nemomobile.lipstick 0.1
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

ListView {
    id: appsListView
    orientation: ListView.Horizontal
    property bool onUninstall
    property alias deleter: deleter
    property var switcher: null
    snapMode: ListView.SnapToItem
    spacing: -width*0.25

    Item {
        id: deleter
        anchors.top: parent.top
        property alias remove: remove
        property alias uninstall: uninstall
        Rectangle {
            id: remove
            property alias text: removeLabel.text
            visible: onUninstall
            height: 110
            color: "red"
            width: appsListView.width / 2
            Label {
                id: removeLabel
                anchors.centerIn: parent
                text: "Remove"
                font.pointSize: 8
            }
        }
        Rectangle {
            id: uninstall
            property alias text: uninstallLabel.text
            anchors.left: remove.right
            visible: onUninstall
            color: "red"
            width: appsListView.width / 2
            height: 110
            Label {
                id: uninstallLabel
                anchors.centerIn: parent
                text: "Uninstall"
                font.pointSize: 8
            }
        }
    }

    model: LauncherFolderModel { id: launcherModel }

    delegate: LauncherItemDelegate {
        id: launcherItem
        width: appsListView.width
        height: appsListView.width
        source: model.object.iconId == "" ? ":/images/icons/apps.png" : (model.object.iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + model.object.iconId
        iconCaption: model.object.title
    }
}
