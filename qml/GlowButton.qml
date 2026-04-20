import QtQuick

Rectangle {
    id: btn
    width: 120; height: 40; radius: 20

    property string text: ""
    property bool buttonEnabled: true
    signal clicked()

    opacity: buttonEnabled ? 1.0 : 0.4
    scale: mouse.pressed ? 0.96 : 1.0
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
            position: 0.0
            color: mouse.containsMouse ? "#80b4ff" : "#5078c8"
            Behavior on color { ColorAnimation { duration: 250 } }
        }
        GradientStop {
            position: 1.0
            color: mouse.containsMouse ? "#c878ff" : "#8050c0"
            Behavior on color { ColorAnimation { duration: 250 } }
        }
    }

    border.width: 1.5
    border.color: mouse.containsMouse ? "#ffffff" : "#60ffffff"
    Behavior on border.color { ColorAnimation { duration: 250 } }

    Text {
        anchors.centerIn: parent
        text: btn.text
        color: "white"
        font.pixelSize: 13
        font.bold: true
        font.family: "Microsoft YaHei"
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: btn.buttonEnabled
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
