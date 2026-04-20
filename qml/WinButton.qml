import QtQuick

Rectangle {
    id: btn
    width: 28; height: 28; radius: 14
    color: mouse.containsMouse ? hoverColor : bgColor

    property string text: ""
    property color bgColor: "#30ffffff"
    property color hoverColor: "#60ffffff"
    signal clicked()

    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text: btn.text
        color: "white"
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
