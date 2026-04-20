import QtQuick

Item {
    id: root
    width: 44; height: 24

    property bool checked: false

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? "#50a0ff" : (root.parent && root.parent.themeDark !== undefined ? "#60ffffff" : "#808080")
        Behavior on color { ColorAnimation { duration: 200 } }

        Rectangle {
            width: 20; height: 20
            radius: 10
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 2 : 2
            color: "white"

            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.checked = !root.checked
        }
    }
}
