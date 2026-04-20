import QtQuick

Rectangle {
    id: btn
    width: 30; height: 30; radius: 15
    color: mouse.containsMouse ? hoverColor : bgColor

    property string text: ""
    property color bgColor: "#30ffffff"
    property color hoverColor: "#60ffffff"
    property color textColor: "white"
    signal clicked()

    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text: btn.text
        color: btn.textColor
        font.pixelSize: 12
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
