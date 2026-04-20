import QtQuick
import QtQuick.Layouts

Item {
    id: bar
    height: 36

    property string title: ""
    property bool themeDark: true
    signal minimize()
    signal close()
    signal dragging(real dx, real dy)
    signal toggleTheme()
    signal openSettings()

    MouseArea {
        anchors.fill: parent
        property point lastPos
        onPressed: (m) => lastPos = Qt.point(m.x, m.y)
        onPositionChanged: (m) => {
            if (pressed) bar.dragging(m.x - lastPos.x, m.y - lastPos.y)
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        Text {
            text: bar.title
            color: bar.themeDark ? "white" : "#1a1a2e"
            font.pixelSize: 16
            font.bold: true
            Layout.leftMargin: 6
        }
        Item { Layout.fillWidth: true }

        // 主题切换按钮
        WinButton {
            text: bar.themeDark ? "☀" : "🌙"
            bgColor: bar.themeDark ? "#40ffffff" : "#40000000"
            hoverColor: bar.themeDark ? "#60ffffff" : "#60000000"
            textColor: bar.themeDark ? "white" : "#1a1a2e"
            onClicked: bar.toggleTheme()
        }

        WinButton {
            text: "⚙"
            bgColor: bar.themeDark ? "#40ffffff" : "#40000000"
            hoverColor: bar.themeDark ? "#60ffffff" : "#60000000"
            textColor: bar.themeDark ? "white" : "#1a1a2e"
            onClicked: bar.openSettings()
        }
        WinButton {
            text: "—"
            bgColor: bar.themeDark ? "#40ffffff" : "#40000000"
            hoverColor: bar.themeDark ? "#60ffffff" : "#60000000"
            textColor: bar.themeDark ? "white" : "#1a1a2e"
            onClicked: bar.minimize()
        }
        WinButton {
            text: "✕"
            bgColor: bar.themeDark ? "#80ff5050" : "#80ff3030"
            hoverColor: bar.themeDark ? "#c8ff3030" : "#ff4040"
            textColor: "white"
            onClicked: bar.close()
        }
    }
}
