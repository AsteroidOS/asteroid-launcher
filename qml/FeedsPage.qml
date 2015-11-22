import QtQuick 2.1
import org.nemomobile.lipstick 0.1
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

Item {
    Flickable {
        id: mainFlickable

        contentHeight: rootitem.height
        contentWidth: parent.width
        Item {
            id: rootitem
            width: parent.width
            height: childrenRect.height

            Column {
                id: notificationColumn
                anchors.top: parent.top
                anchors.topMargin: 20
                spacing: 10
                Repeater {
                    model: NotificationListModel {
                        id: notifmodel
                    }
                    delegate:
                        MouseArea {
                            height: Math.max(appSummary.height,appBody.height)
                            width: rootitem.width

                            onClicked: {
                                if (modelData.userRemovable) {
                                    modelData.actionInvoked("default")
                                }
                            }

                            Image {
                                id: appIcon
                                source: {
                                    if (modelData.icon)
                                        return "image://theme/" + modelData.icon
                                    else
                                        return ""
                                }
                            }

                            Label {
                                id: appSummary
                                text: modelData.summary
                                width: (rootitem.width-appIcon.width)/2
                                font.pointSize: 10
                                anchors.left: appIcon.right
                                wrapMode: Text.Wrap
                            }
                            Label {
                                id: appBody
                                width: (rootitem.width-appIcon.width)/2
                                text: modelData.body
                                font.pointSize: 8
                                wrapMode: Text.Wrap
                                anchors.left: appSummary.right
                            }
                        }
                    }
                }
            }
    }

    Label {
        visible: notifmodel.itemCount === 0
        horizontalAlignment: Text.AlignHCenter

        text: "<b>No new<br>notification</b>"
        font.pointSize: 12
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
    }
}
