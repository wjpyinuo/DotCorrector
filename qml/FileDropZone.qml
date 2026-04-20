import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    radius: 15
    color: "transparent"
    border.width: 2

    property bool dragging: false
    property var files: []
    property bool busy: false
    property int progress: 0
    property string status: ""

    // 主题属性
    property bool themeDark: true
    property color zoneBorder: "#50ffffff"
    property color zoneDragBorder: "#80e0ff"
    property color textColor: "white"
    property color textSecColor: "#b0ffffff"
    property color glowColor: "#80e0ff"
    property color progBg: "#30ffffff"
    property color progStart: "#80e0ff"
    property color progEnd: "#c878ff"

    border.color: dragging ? zoneDragBorder : zoneBorder
    Behavior on border.color { ColorAnimation { duration: 200 } }

    DropArea {
        id: dropTarget
        anchors.fill: parent
        onEntered: (drag) => {
            root.dragging = true
            drag.accept()
        }
        onExited: root.dragging = false
        onDropped: (drop) => {
            root.dragging = false
            let list = []
            for (let i = 0; i < drop.urls.length; i++) {
                list.push(drop.urls[i].toString().replace("file:///", ""))
            }
            root.files = list
        }
    }

    // 中心提示
    Column {
        anchors.centerIn: parent
        spacing: 12
        visible: !root.busy

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.files.length > 0
                ? "已选择 " + root.files.length + " 个文件"
                : "拖入文件到这里"
            color: root.textColor
            font.pixelSize: 16
            font.bold: true
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "支持 docx / xlsx / pptx / txt"
            color: root.textSecColor
            font.pixelSize: 12
        }

        // 呼吸光点动画
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 10; height: 10; radius: 5
            color: root.glowColor
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.2; duration: 800 }
                NumberAnimation { to: 1.0; duration: 800 }
            }
        }
    }

    // 进度条（处理中显示）
    Column {
        anchors.centerIn: parent
        spacing: 15
        visible: root.busy
        width: parent.width * 0.6

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.status
            color: root.textColor
            font.pixelSize: 14
        }

        Rectangle {
            width: parent.width; height: 6; radius: 3
            color: root.progBg
            Rectangle {
                width: parent.width * (root.progress / 100)
                height: parent.height
                radius: 3
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: root.progStart }
                    GradientStop { position: 1; color: root.progEnd }
                }
                Behavior on width { NumberAnimation { duration: 100 } }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.progress + "%"
            color: root.textSecColor
            font.pixelSize: 12
        }
    }
}
