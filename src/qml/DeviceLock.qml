import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtQuick.Layouts 1.0

Item {
    id: root
    anchors.top: clock.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    ColumnLayout {
        anchors.fill: parent
        spacing: 40
        TextField {
            id: lockCodeField
            readOnly: true
            echoMode: TextInput.PasswordEchoOnEdit
        }

        GridLayout {
            height: parent.height
            width: parent.width
            columns: 3
            Repeater {
                model: ["1","2","3","4","5","6","7","8","9","Ca","0","OK"]
                delegate:
                Button {
                    Layout.fillWidth: true
                    text: modelData
                    onClicked: {
                        if (text !== "Ca" && text !== "OK") {
                            lockCodeField.insert(lockCodeField.cursorPosition, text)
                        } else {
                            if (text === "OK") {
                                if(deviceLock.checkCode(lockCodeField.text)) {
                                    deviceLock.setState(0)
                                    lockCodeField.text = ""
                                } else {
                                    lockCodeField.text = ""
                                }
                            } else if (text === "Ca"){
                                lockCodeField.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
}
