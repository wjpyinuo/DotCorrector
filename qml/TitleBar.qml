import QtQuick

Item {
    id: bar
    height: 40
    clip: true

    property string title: ""
    property bool themeDark: true
    property bool pinned: false
    signal minimize()
    signal close()
    signal dragging(real dx, real dy)
    signal toggleTheme()
    signal togglePin()
    signal openSettings()

    MouseArea {
        x: 0; y: 0
        width: bar.width - 150
        height: bar.height
        property point lastPos
        onPressed: (m) => lastPos = Qt.point(m.x, m.y)
        onPositionChanged: (m) => {
            if (pressed) bar.dragging(m.x - lastPos.x, m.y - lastPos.y)
        }
    }

    Text {
        id: titleText
        x: 10
        y: (bar.height - height) / 2
        text: bar.title
        color: bar.themeDark ? "white" : "#1a1a2e"
        font.pixelSize: 15
        font.bold: true
    }

    // 按钮 - 从右到左排列
    WinButton {
        x: bar.width - 32; y: 6
        width: 28; height: 28; radius: 14
        text: "✕"
        bgColor: bar.themeDark ? "#80ff5050" : "#80ff3030"
        hoverColor: bar.themeDark ? "#c8ff3030" : "#ff4040"
        textColor: "white"
        onClicked: bar.close()
    }
    WinButton {
        x: bar.width - 64; y: 6
        width: 28; height: 28; radius: 14
        text: "—"
        bgColor: bar.themeDark ? "#40ffffff" : "#40000000"
        hoverColor: bar.themeDark ? "#60ffffff" : "#60000000"
        textColor: bar.themeDark ? "white" : "#1a1a2e"
        onClicked: bar.minimize()
    }
    WinButton {
        x: bar.width - 96; y: 6
        width: 28; height: 28; radius: 14
        text: "⚙"
        bgColor: bar.themeDark ? "#40ffffff" : "#40000000"
        hoverColor: bar.themeDark ? "#60ffffff" : "#60000000"
        textColor: bar.themeDark ? "white" : "#1a1a2e"
        onClicked: bar.openSettings()
    }
    WinButton {
        x: bar.width - 128; y: 6
        width: 28; height: 28; radius: 14
        text: bar.pinned ? "📌" : "📍"
        bgColor: bar.pinned ? (bar.themeDark ? "#6080e0ff" : "#604090ff") : (bar.themeDark ? "#40ffffff" : "#40000000")
        hoverColor: bar.themeDark ? "#60ffffff" : "#60000000"
        textColor: bar.themeDark ? "white" : "#1a1a2e"
        onClicked: bar.togglePin()
    }
    WinButton {
        x: bar.width - 160; y: 6
        width: 28; height: 28; radius: 14
        text: bar.themeDark ? "☀" : "🌙"
        bgColor: bar.themeDark ? "#40ffffff" : "#40000000"
        hoverColor: bar.themeDark ? "#60ffffff" : "#60000000"
        textColor: bar.themeDark ? "white" : "#1a1a2e"
        onClicked: bar.toggleTheme()
    }
}
