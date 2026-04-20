import QtQuick
import QtQuick.Layouts

Item {
    id: bar
    height: 36

    property string title: ""
    signal minimize()
    signal close()
    signal dragging(real dx, real dy)

    // 拖拽区
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
            color: "white"
            font.pixelSize: 16
            font.bold: true
            Layout.leftMargin: 6
        }
        Item { Layout.fillWidth: true }

        WinButton { text: "—"; onClicked: bar.minimize(); bgColor: "#40ffffff" }
        WinButton { text: "✕"; onClicked: bar.close();   bgColor: "#80ff5050"; hoverColor: "#c8ff3030" }
    }
}
