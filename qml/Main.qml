import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import App.Backend

Window {
    id: root
    width: 720
    height: 480
    minimumWidth: 600
    minimumHeight: 400
    visible: true
    flags: Qt.FramelessWindowHint | Qt.Window
    color: "transparent"

    property point dragPos: Qt.point(0, 0)

    Backend { id: backend }

    // ============ 异形背景 ============
    Rectangle {
        id: bgCard
        anchors.fill: parent
        anchors.margins: 15
        radius: 20
        border.width: 1.5
        border.color: fileDropZone.dragging
            ? Qt.rgba(0.5, 0.9, 1.0, 1.0)
            : Qt.rgba(1, 1, 1, 0.15)

        // 边框颜色过渡动画
        Behavior on border.color {
            ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#2a2e5a" }
            GradientStop { position: 1.0; color: "#5a2878" }
        }

        // 顶部高光
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 80
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1,1,1,0.18) }
                GradientStop { position: 1.0; color: Qt.rgba(1,1,1,0) }
            }
        }

        // 外发光（拖入文件时显现）
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 1.0
            shadowColor: "#80b4ff"
            shadowOpacity: fileDropZone.dragging ? 0.8 : 0.0
            Behavior on shadowOpacity {
                NumberAnimation { duration: 300 }
            }
        }

        // ============ 内容布局 ============
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            TitleBar {
                Layout.fillWidth: true
                title: "✨ 智能错别字纠正"
                onMinimize: root.showMinimized()
                onClose: closeAnim.start()
                onDragging: (dx, dy) => {
                    root.x += dx
                    root.y += dy
                }
            }

            FileDropZone {
                id: fileDropZone
                Layout.fillWidth: true
                Layout.fillHeight: true
                busy: backend.busy
                progress: backend.progress
                status: backend.status
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                GlowButton {
                    text: backend.busy ? "处理中..." : "开始纠错"
                    buttonEnabled: !backend.busy && fileDropZone.files.length > 0
                    onClicked: backend.startCorrect(fileDropZone.files)
                }
                GlowButton { text: "设置" }
            }
        }
    }

    // ============ 启动动画 ============
    ParallelAnimation {
        id: startupAnim
        running: true
        NumberAnimation {
            target: root; property: "opacity"
            from: 0; to: 1; duration: 500
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: bgCard; property: "scale"
            from: 0.85; to: 1.0; duration: 500
            easing.type: Easing.OutBack
        }
    }

    // ============ 关闭动画 ============
    SequentialAnimation {
        id: closeAnim
        NumberAnimation {
            target: root; property: "opacity"
            to: 0; duration: 250; easing.type: Easing.InCubic
        }
        ScriptAction { script: root.close() }
    }
}
