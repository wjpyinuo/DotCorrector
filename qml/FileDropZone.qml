import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    radius: 15
    color: "transparent"
    border.width: 2
    border.color: dragging ? "#80e0ff" : "#50ffffff"

    property bool dragging: false
    property var files: []
    property bool busy: false
    property int progress: 0
    property string status: ""

    // 虚线边框效果（用重复小矩形模拟）
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
            color: "white"
            font.pixelSize: 16
            font.bold: true
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "支持 docx / xlsx / pptx / txt"
            color: "#b0ffffff"
            font.pixelSize: 12
        }

        // 呼吸光点动画
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 10; height: 10; radius: 5
            color: "#80e0ff"
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
            color: "white"
            font.pixelSize: 14
        }

        Rectangle {
            width: parent.width; height: 6; radius: 3
            color: "#30ffffff"
            Rectangle {
                width: parent.width * (root.progress / 100)
                height: parent.height
                radius: 3
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "#80e0ff" }
                    GradientStop { position: 1; color: "#c878ff" }
                }
                Behavior on width { NumberAnimation { duration: 100 } }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.progress + "%"
            color: "#e0ffffff"
            font.pixelSize: 12
        }
    }
}
