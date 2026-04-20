import QtQuick

Rectangle {
    id: btn
    width: 110; height: 38; radius: 19

    property string text: ""
    property bool buttonEnabled: true
    property bool themeDark: true

    // 主题颜色（外部传入）
    property color gradStartNormal: "#5078c8"
    property color gradEndNormal: "#8050c0"
    property color gradStartHover: "#80b4ff"
    property color gradEndHover: "#c878ff"
    property color borderColorNormal: "#60ffffff"
    property color borderColorHover: "#ffffff"

    signal clicked()

    opacity: buttonEnabled ? 1.0 : 0.4
    scale: mouse.pressed ? 0.96 : 1.0
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
            position: 0.0
            color: mouse.containsMouse ? btn.gradStartHover : btn.gradStartNormal
            Behavior on color { ColorAnimation { duration: 250 } }
        }
        GradientStop {
            position: 1.0
            color: mouse.containsMouse ? btn.gradEndHover : btn.gradEndNormal
            Behavior on color { ColorAnimation { duration: 250 } }
        }
    }

    border.width: 1.5
    border.color: mouse.containsMouse ? btn.borderColorHover : btn.borderColorNormal
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
