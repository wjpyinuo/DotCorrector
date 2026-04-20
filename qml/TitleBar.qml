import QtQuick

Item {
    id: bar
    height: 40

    property string title: ""
    property bool themeDark: true
    property bool pinned: false
    signal minimize()
    signal close()
    signal dragging(real dx, real dy)
    signal toggleTheme()
    signal togglePin()
    signal openSettings()

    // 拖拽区域
    MouseArea {
        anchors.fill: parent
        property point lastPos
        onPressed: (m) => lastPos = Qt.point(m.x, m.y)
        onPositionChanged: (m) => {
            if (pressed) bar.dragging(m.x - lastPos.x, m.y - lastPos.y)
        }
    }

    // 标题
    Text {
        id: titleText
        x: 10
        anchors.verticalCenter: parent.verticalCenter
        text: bar.title
        color: bar.themeDark ? "white" : "#1a1a2e"
        font.pixelSize: 15
        font.bold: true
        elide: Text.ElideRight
        width: Math.min(implicitWidth, bar.width - btnsRow.width - 30)
    }

    // 右侧按钮组（绝对定位）
    Row {
        id: btnsRow
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        WinButton {
            text: bar.themeDark ? "☀" : "🌙"
            width: 28; height: 28; radius: 14
            bgColor: bar.themeDark ? "#40ffffff" : "#40000000"
            hoverColor: bar.themeDark ? "#60ffffff" : "#60000000"
            textColor: bar.themeDark ? "white" : "#1a1a2e"
            onClicked: bar.toggleTheme()
        }
        WinButton {
            text: bar.pinned ? "📌" : "📍"
            width: 28; height: 28; radius: 14
            bgColor: bar.pinned ? (bar.themeDark ? "#6080e0ff" : "#604090ff") : (bar.themeDark ? "#40ffffff" : "#40000000")
            hoverColor: bar.themeDark ? "#60ffffff" : "#60000000"
            textColor: bar.themeDark ? "white" : "#1a1a2e"
            onClicked: bar.togglePin()
        }
        WinButton {
            text: "⚙"
            width: 28; height: 28; radius: 14
            bgColor: bar.themeDark ? "#40ffffff" : "#40000000"
            hoverColor: bar.themeDark ? "#60ffffff" : "#60000000"
            textColor: bar.themeDark ? "white" : "#1a1a2e"
            onClicked: bar.openSettings()
        }
        WinButton {
            text: "—"
            width: 28; height: 28; radius: 14
            bgColor: bar.themeDark ? "#40ffffff" : "#40000000"
            hoverColor: bar.themeDark ? "#60ffffff" : "#60000000"
            textColor: bar.themeDark ? "white" : "#1a1a2e"
            onClicked: bar.minimize()
        }
        WinButton {
            text: "✕"
            width: 28; height: 28; radius: 14
            bgColor: bar.themeDark ? "#80ff5050" : "#80ff3030"
            hoverColor: bar.themeDark ? "#c8ff3030" : "#ff4040"
            textColor: "white"
            onClicked: bar.close()
        }
    }
}
