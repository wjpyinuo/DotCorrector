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

    // ============ 待机状态：空 ============
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -12
        spacing: 14
        visible: !root.busy && root.files.length === 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "拖入文件到这里"
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

    // ============ 已选文件列表 ============
    Column {
        anchors { fill: parent; margins: 20 }
        spacing: 8
        visible: !root.busy && root.files.length > 0

        Row {
            spacing: 8

            Text {
                text: "已选择 " + root.files.length + " 个文件"
                color: root.textColor
                font.pixelSize: 14
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            // 清空按钮
            Rectangle {
                width: clearText.width + 16; height: 26; radius: 13
                color: clearMouse.containsMouse ? (root.themeDark ? "#60ffffff" : "#60000000") : (root.themeDark ? "#30ffffff" : "#30000000")
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    id: clearText
                    anchors.centerIn: parent
                    text: "清空"
                    color: root.textSecColor
                    font.pixelSize: 11
                }
                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.files = []
                }
            }
        }

        Text {
            text: "支持 docx / xlsx / pptx / txt"
            color: root.textSecColor
            font.pixelSize: 11
        }

        ListView {
            width: parent.width
            height: parent.height - 60
            clip: true
            model: root.files
            spacing: 4

            delegate: Rectangle {
                width: parent ? parent.width : 300
                height: 46
                radius: 8
                color: root.themeDark ? "#15ffffff" : "#08000000"
                border.width: 1
                border.color: root.themeDark ? "#20ffffff" : "#15000000"

                Row {
                    anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                    spacing: 10

                    // 文件图标
                    Text {
                        text: {
                            let ext = modelData.split('.').pop().toLowerCase()
                            if (ext === "docx") return "📄"
                            if (ext === "xlsx") return "📊"
                            if (ext === "pptx") return "📑"
                            return "📝"
                        }
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: {
                                let parts = modelData.split('/')
                                return parts[parts.length - 1]
                            }
                            color: root.textColor
                            font.pixelSize: 12
                            font.bold: true
                        }

                        Text {
                            text: modelData
                            color: root.textSecColor
                            font.pixelSize: 9
                            elide: Text.ElideMiddle
                            width: Math.min(implicitWidth, 400)
                        }
                    }
                }

                // 移除按钮
                Rectangle {
                    anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                    width: 22; height: 22; radius: 11
                    color: removeMouse.containsMouse ? (root.themeDark ? "#60ff5050" : "#60ff3030") : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: root.textSecColor
                        font.pixelSize: 10
                    }
                    MouseArea {
                        id: removeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let newList = []
                            for (let i = 0; i < root.files.length; i++) {
                                if (i !== index) newList.push(root.files[i])
                            }
                            root.files = newList
                        }
                    }
                }
            }
        }
    }

    // ============ 处理中：进度条 ============
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
                Behavior on width { NumberAnimation { duration: 200 } }
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
