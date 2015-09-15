import QtQuick 2.0
import QtQuick.Controls.Nemo 1.0

Item {
    id: toolsLayoutItem

    anchors.fill: parent

    property string title: ""
    property StackView pageStack: findStackView(toolsLayoutItem)

    //XXX: TEMPORARY CODE, MIGHT CAUSE LAG WHEN PUSHING A PAGE ON THE STACK
    function findStackView(startingItem) {
        var myStack = startingItem
        while (myStack) {
            if (myStack.hasOwnProperty("currentItem") && myStack.hasOwnProperty("initialItem"))
                    return myStack
            myStack = myStack.parent
        }
        return null
    }

    Rectangle {
        id: backButton
        width: opacity ? 60 : 0
        anchors.left: parent.left
        anchors.leftMargin: 20
        //check if Stack.view has already been initialized as well
        opacity: (pageStack && (pageStack.depth > 1)) ? 1 : 0
        anchors.verticalCenter: parent.verticalCenter
        antialiasing: true
        height: 60
        radius: 4
        color: backmouse.pressed ? "#222" : "transparent"
        Behavior on opacity { NumberAnimation{} }
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/navigation_previous_item.png"
        }
        MouseArea {
            id: backmouse
            anchors.fill: parent
            anchors.margins: -10
            onClicked: pageStack.pop()
        }
    }

    Label {
        font.pixelSize: 42
        Behavior on x { NumberAnimation { easing.type: Easing.OutCubic } }
        x: backButton.x + backButton.width + 20
        anchors.verticalCenter: parent.verticalCenter
        text: parent.title
    }
}
