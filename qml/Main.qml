import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
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

    property var droppedFiles: []

    // ============ 主题系统 ============
    QtObject {
        id: theme
        property bool dark: true

        // 深色主题
        property color bgStart: dark ? "#2a2e5a" : "#f0f4ff"
        property color bgEnd: dark ? "#5a2878" : "#e8d0f0"
        property color textPrimary: dark ? "white" : "#1a1a2e"
        property color textSecondary: dark ? "#b0ffffff" : "#666680"
        property color borderNormal: dark ? Qt.rgba(1,1,1,0.15) : Qt.rgba(0,0,0,0.1)
        property color borderDrag: dark ? Qt.rgba(0.5,0.9,1.0,1.0) : Qt.rgba(0.3,0.6,1.0,1.0)
        property color dropZoneBorder: dark ? "#50ffffff" : "#50000000"
        property color dropZoneDragBorder: dark ? "#80e0ff" : "#4090ff"
        property color glowDot: dark ? "#80e0ff" : "#4090ff"
        property color cardBg: dark ? "transparent" : Qt.rgba(1,1,1,0.6)
        property color winBtnBg: dark ? "#40ffffff" : "#40000000"
        property color winBtnHover: dark ? "#60ffffff" : "#60000000"
        property color closeBtnBg: dark ? "#80ff5050" : "#80ff3030"
        property color closeBtnHover: dark ? "#c8ff3030" : "#ff4040"
        property color progressBg: dark ? "#30ffffff" : "#30000000"
        property color progressBarStart: dark ? "#80e0ff" : "#4090ff"
        property color progressBarEnd: dark ? "#c878ff" : "#8060c0"
        property color settingLabel: dark ? "#c0ffffff" : "#444466"

        // 按钮渐变
        property color btnGradStartNormal: dark ? "#5078c8" : "#4070c0"
        property color btnGradEndNormal: dark ? "#8050c0" : "#7040a0"
        property color btnGradStartHover: dark ? "#80b4ff" : "#6098e0"
        property color btnGradEndHover: dark ? "#c878ff" : "#a070d0"
        property color btnBorderNormal: dark ? "#60ffffff" : "#60000000"
        property color btnBorderHover: dark ? "#ffffff" : "#202040"
    }

    Backend { id: backend }

    // ============ 异形背景 ============
    Rectangle {
        id: bgCard
        anchors.fill: parent
        anchors.margins: 0
        radius: 20
        border.width: 0
        border.color: theme.borderNormal

        Behavior on border.color {
            ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: theme.bgStart }
            GradientStop { position: 1.0; color: theme.bgEnd }
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

        // ============ StackView 页面切换 ============
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            TitleBar {
                Layout.fillWidth: true
                title: "墨正 DotCorrector"
                themeDark: theme.dark
                onMinimize: root.showMinimized()
                onClose: closeAnim.start()
                onDragging: (dx, dy) => {
                    root.x += dx
                    root.y += dy
                }
                onToggleTheme: theme.dark = !theme.dark
                onOpenSettings: {
                    if (pageStack.depth === 1)
                        pageStack.push(settingsPage)
                }
            }

            StackView {
                id: pageStack
                Layout.fillWidth: true
                Layout.fillHeight: true

                initialItem: mainPage

                pushEnter: Transition {
                    PropertyAnimation {
                        property: "x"
                        from: pageStack.width; to: 0
                        duration: 300; easing.type: Easing.OutCubic
                    }
                    PropertyAnimation {
                        property: "opacity"
                        from: 0; to: 1
                        duration: 300
                    }
                }
                pushExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1; to: 0
                        duration: 250
                    }
                }
                popEnter: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0; to: 1
                        duration: 250
                    }
                }
                popExit: Transition {
                    PropertyAnimation {
                        property: "x"
                        from: 0; to: pageStack.width
                        duration: 300; easing.type: Easing.OutCubic
                    }
                    PropertyAnimation {
                        property: "opacity"
                        from: 1; to: 0
                        duration: 300
                    }
                }

                Component {
                    id: mainPage
                    Item {
                        FileDropZone {
                            id: fileDropZone
                            anchors.fill: parent
                            busy: backend.busy
                            progress: backend.progress
                            status: backend.status
                            themeDark: theme.dark
                            zoneBorder: theme.dropZoneBorder
                            zoneDragBorder: theme.dropZoneDragBorder
                            textColor: theme.textPrimary
                            textSecColor: theme.textSecondary
                            glowColor: theme.glowDot
                            progBg: theme.progressBg
                            progStart: theme.progressBarStart
                            progEnd: theme.progressBarEnd
                            onFilesChanged: root.droppedFiles = files
                        }
                    }
                }

                Component {
                    id: settingsPage
                    SettingsPage {
                        themeDark: theme.dark
                        labelColor: theme.settingLabel
                        textColor: theme.textPrimary
                        bgColor: theme.bgStart
                        onBack: pageStack.pop()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                GlowButton {
                    text: backend.busy ? "处理中..." : "开始纠错"
                    buttonEnabled: !backend.busy && root.droppedFiles.length > 0
                    onClicked: backend.startCorrect(root.droppedFiles)
                    themeDark: theme.dark
                    gradStartNormal: theme.btnGradStartNormal
                    gradEndNormal: theme.btnGradEndNormal
                    gradStartHover: theme.btnGradStartHover
                    gradEndHover: theme.btnGradEndHover
                    borderColorNormal: theme.btnBorderNormal
                    borderColorHover: theme.btnBorderHover
                }
                GlowButton {
                    text: "设置"
                    onClicked: {
                        if (pageStack.depth === 1)
                            pageStack.push(settingsPage)
                    }
                    themeDark: theme.dark
                    gradStartNormal: theme.btnGradStartNormal
                    gradEndNormal: theme.btnGradEndNormal
                    gradStartHover: theme.btnGradStartHover
                    gradEndHover: theme.btnGradEndHover
                    borderColorNormal: theme.btnBorderNormal
                    borderColorHover: theme.btnBorderHover
                }
            }
        }
    }

    // ============ 窗口边缘缩放 ============
    property int edge: 4

    // 左边缘
    MouseArea {
        width: root.edge; anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        cursorShape: Qt.SizeHorCursor
        property real startX
        onPressed: (m) => startX = m.globalX
        onPositionChanged: (m) => {
            if (pressed) {
                let dx = m.globalX - startX
                root.x += dx; root.width -= dx
                startX = m.globalX
            }
        }
    }
    // 右边缘
    MouseArea {
        width: root.edge; anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        cursorShape: Qt.SizeHorCursor
        property real startX
        onPressed: (m) => startX = m.globalX
        onPositionChanged: (m) => {
            if (pressed) {
                root.width += m.globalX - startX
                startX = m.globalX
            }
        }
    }
    // 上边缘
    MouseArea {
        height: root.edge; anchors { top: parent.top; left: parent.left; right: parent.right }
        cursorShape: Qt.SizeVerCursor
        property real startY
        onPressed: (m) => startY = m.globalY
        onPositionChanged: (m) => {
            if (pressed) {
                let dy = m.globalY - startY
                root.y += dy; root.height -= dy
                startY = m.globalY
            }
        }
    }
    // 下边缘
    MouseArea {
        height: root.edge; anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        cursorShape: Qt.SizeVerCursor
        property real startY
        onPressed: (m) => startY = m.globalY
        onPositionChanged: (m) => {
            if (pressed) {
                root.height += m.globalY - startY
                startY = m.globalY
            }
        }
    }
    // 左上角
    MouseArea {
        width: root.edge + 6; height: root.edge + 6; anchors { left: parent.left; top: parent.top }
        cursorShape: Qt.SizeFDiagCursor
        property point start
        onPressed: (m) => start = Qt.point(m.globalX, m.globalY)
        onPositionChanged: (m) => {
            if (pressed) {
                let dx = m.globalX - start.x; let dy = m.globalY - start.y
                root.x += dx; root.width -= dx; root.y += dy; root.height -= dy
                start = Qt.point(m.globalX, m.globalY)
            }
        }
    }
    // 右上角
    MouseArea {
        width: root.edge + 6; height: root.edge + 6; anchors { right: parent.right; top: parent.top }
        cursorShape: Qt.SizeBDiagCursor
        property point start
        onPressed: (m) => start = Qt.point(m.globalX, m.globalY)
        onPositionChanged: (m) => {
            if (pressed) {
                root.width += m.globalX - start.x
                let dy = m.globalY - start.y
                root.y += dy; root.height -= dy
                start = Qt.point(m.globalX, m.globalY)
            }
        }
    }
    // 左下角
    MouseArea {
        width: root.edge + 6; height: root.edge + 6; anchors { left: parent.left; bottom: parent.bottom }
        cursorShape: Qt.SizeBDiagCursor
        property point start
        onPressed: (m) => start = Qt.point(m.globalX, m.globalY)
        onPositionChanged: (m) => {
            if (pressed) {
                let dx = m.globalX - start.x
                root.x += dx; root.width -= dx
                root.height += m.globalY - start.y
                start = Qt.point(m.globalX, m.globalY)
            }
        }
    }
    // 右下角
    MouseArea {
        width: root.edge + 6; height: root.edge + 6; anchors { right: parent.right; bottom: parent.bottom }
        cursorShape: Qt.SizeFDiagCursor
        property point start
        onPressed: (m) => start = Qt.point(m.globalX, m.globalY)
        onPositionChanged: (m) => {
            if (pressed) {
                root.width += m.globalX - start.x
                root.height += m.globalY - start.y
                start = Qt.point(m.globalX, m.globalY)
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
