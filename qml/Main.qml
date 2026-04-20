import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import App.Backend

Window {
    id: root
    width: 860
    height: 560
    minimumWidth: 700
    minimumHeight: 460
    visible: true
    flags: Qt.FramelessWindowHint | Qt.Window
    color: "transparent"

    property var droppedFiles: []
    property bool showPreview: false
    property bool pinned: false

    // ============ 主题系统 ============
    QtObject {
        id: theme
        property bool dark: true

        property color bgStart: dark ? "#2a2e5a" : "#f0f4ff"
        property color bgEnd: dark ? "#5a2878" : "#e8d0f0"
        property color textPrimary: dark ? "white" : "#1a1a2e"
        property color textSecondary: dark ? "#b0ffffff" : "#666680"
        property color borderNormal: dark ? Qt.rgba(1,1,1,0.15) : Qt.rgba(0,0,0,0.1)
        property color borderDrag: dark ? Qt.rgba(0.5,0.9,1.0,1.0) : Qt.rgba(0.3,0.6,1.0,1.0)
        property color dropZoneBorder: dark ? "#50ffffff" : "#50000000"
        property color dropZoneDragBorder: dark ? "#80e0ff" : "#4090ff"
        property color glowDot: dark ? "#80e0ff" : "#4090ff"
        property color winBtnBg: dark ? "#40ffffff" : "#40000000"
        property color winBtnHover: dark ? "#60ffffff" : "#60000000"
        property color closeBtnBg: dark ? "#80ff5050" : "#80ff3030"
        property color closeBtnHover: dark ? "#c8ff3030" : "#ff4040"
        property color progressBg: dark ? "#30ffffff" : "#30000000"
        property color progressBarStart: dark ? "#80e0ff" : "#4090ff"
        property color progressBarEnd: dark ? "#c878ff" : "#8060c0"
        property color settingLabel: dark ? "#c0ffffff" : "#444466"

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
        radius: 20

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

        // ============ 主布局（绝对定位，避免约束求解问题）============
        Item {
            id: mainLayout
            x: 20; y: 20
            width: parent.width - 40
            height: parent.height - 48

            TitleBar {
                id: titleBar
                x: 0; y: 0
                width: parent.width
                title: "墨正 DotCorrector"
                themeDark: theme.dark
                pinned: root.pinned
                onMinimize: root.showMinimized()
                onClose: closeAnim.start()
                onDragging: (dx, dy) => {
                    root.x += dx
                    root.y += dy
                }
                onToggleTheme: theme.dark = !theme.dark
                onTogglePin: {
                    root.pinned = !root.pinned
                    if (root.pinned) {
                        root.flags = root.flags | Qt.WindowStaysOnTopHint
                    } else {
                        root.flags = (root.flags | Qt.WindowStaysOnTopHint) ^ Qt.WindowStaysOnTopHint
                    }
                }
                onOpenSettings: {
                    if (root.showPreview) {
                        root.showPreview = false
                    } else if (pageStack.depth === 1) {
                        pageStack.push(settingsPage)
                    }
                }
            }

            StackView {
                id: pageStack
                x: 0
                y: titleBar.height + 15
                width: parent.width
                height: parent.height - titleBar.height - bottomBar.height - 30

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
                            width: parent.width
                            height: parent.height
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

                        // 绑定后端设置
                        useDict: backend.useDict
                        usePycorrector: backend.usePycorrector
                        useLlm: backend.useLlm
                        apiKey: backend.apiKey
                        apiProvider: backend.apiProvider

                        onBack: pageStack.pop()
                        onDictToggled: (v) => backend.useDict = v
                        onPycorrectorToggled: (v) => backend.usePycorrector = v
                        onLlmToggled: (v) => backend.useLlm = v
                        onApiKeyUpdated: (v) => backend.apiKey = v
                        onApiProviderUpdated: (v) => backend.apiProvider = v
                    }
                }
            }

            // 底部按钮行（绝对定位）
            Item {
                id: bottomBar
                x: 0
                y: parent.height - height
                width: parent.width
                height: 42
                visible: !root.showPreview

                // 状态文本
                Text {
                    x: 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: backend.status
                    color: theme.textSecondary
                    font.pixelSize: 11
                    visible: !backend.busy
                }

                // 右侧按钮
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    GlowButton {
                        text: "设置"
                        onClicked: {
                            if (pageStack.depth === 1 && !root.showPreview)
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

                    GlowButton {
                        text: "查看结果"
                        buttonEnabled: !backend.busy && backend.resultsJson !== "[]"
                        onClicked: {
                            if (pageStack.depth > 1)
                                pageStack.pop()
                            root.showPreview = true
                        }
                        themeDark: theme.dark
                        gradStartNormal: theme.btnGradStartNormal
                        gradEndNormal: theme.btnGradEndNormal
                        gradStartHover: theme.btnGradStartHover
                        gradEndHover: theme.btnGradEndHover
                        borderColorNormal: theme.btnBorderNormal
                        borderColorHover: theme.btnBorderHover
                    }

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
                }
            }
        }
    }

    // ============ 预览页面覆盖层 ============
    PreviewPage {
        id: previewOverlay
        anchors.fill: parent
        anchors.margins: 20
        visible: root.showPreview
        themeDark: theme.dark
        textColor: theme.textPrimary
        labelColor: theme.textSecondary
        bgColor: theme.bgStart
        resultsJson: backend.resultsJson
        totalChanges: backend.totalChanges
        dictChanges: backend.dictChanges
        pycChanges: backend.pycChanges
        llmChanges: backend.llmChanges

        onBack: root.showPreview = false
        onAcceptChange: (segIndex, changeIndex) => backend.setChangeAccepted(segIndex, changeIndex, true)
        onRejectChange: (segIndex, changeIndex) => backend.setChangeAccepted(segIndex, changeIndex, false)
        onAcceptAll: backend.acceptAllChanges(0)
        onRejectAll: backend.rejectAllChanges(0)
        onExportClicked: {
            // 导出到源文件同目录
            if (root.droppedFiles.length > 0) {
                let firstFile = root.droppedFiles[0].toString().replace("file:///", "")
                let dir = firstFile.substring(0, firstFile.lastIndexOf("/"))
                backend.exportResults(dir)
            }
        }

        opacity: root.showPreview ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    // ============ 窗口边缘缩放 ============
    property int edge: 4

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
