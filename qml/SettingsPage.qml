import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool themeDark: true
    property color labelColor: "#c0ffffff"
    property color textColor: "white"
    property color bgColor: "#2a2e5a"

    signal back()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // 返回按钮
        Row {
            spacing: 8
            Layout.fillWidth: true

            Rectangle {
                width: 60; height: 28; radius: 14
                color: backMouse.containsMouse ? (root.themeDark ? "#60ffffff" : "#60000000") : (root.themeDark ? "#30ffffff" : "#30000000")
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "← 返回"
                    color: root.textColor
                    font.pixelSize: 12
                }
                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.back()
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "设置"
                color: root.textColor
                font.pixelSize: 18
                font.bold: true
            }
        }

        // 纠错引擎设置
        Text {
            text: "纠错引擎"
            color: root.textColor
            font.pixelSize: 15
            font.bold: true
        }

        // 本地纠错开关
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ToggleSwitch {
                checked: true
                dark: root.themeDark
            }
            Column {
                Text { text: "本地纠错（免费）"; color: root.textColor; font.pixelSize: 13; font.bold: true }
                Text { text: "错别字词典 + pycorrector，无需联网"; color: root.labelColor; font.pixelSize: 11 }
            }
            Item { Layout.fillWidth: true }
        }

        // AI精校开关
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ToggleSwitch {
                id: aiToggle
                checked: false
                dark: root.themeDark
            }
            Column {
                Text { text: "AI 精校（需 API Key）"; color: root.textColor; font.pixelSize: 13; font.bold: true }
                Text { text: "调用大模型 API，纠错精度更高"; color: root.labelColor; font.pixelSize: 11 }
            }
            Item { Layout.fillWidth: true }
        }

        // API Key 输入区
        ColumnLayout {
            visible: aiToggle.checked
            Layout.fillWidth: true
            spacing: 8
            Layout.leftMargin: 40

            Text {
                text: "API Key"
                color: root.labelColor
                font.pixelSize: 12
            }

            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: 8
                color: root.themeDark ? "#40ffffff" : "#40000000"
                border.width: 1
                border.color: root.themeDark ? "#60ffffff" : "#40000000"

                TextInput {
                    id: apiKeyInput
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.textColor
                    font.pixelSize: 12
                    clip: true
                    echoMode: TextInput.Password
                }

                Text {
                    anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                    text: "输入你的 MiMo API Key..."
                    color: root.themeDark ? "#60ffffff" : "#60000000"
                    font.pixelSize: 12
                    visible: apiKeyInput.text.length === 0 && !apiKeyInput.activeFocus
                }
            }

            // 余额显示
            Row {
                spacing: 6
                Text { text: "💰"; font.pixelSize: 12 }
                Text { text: "余额：-- 元"; color: root.labelColor; font.pixelSize: 11 }
            }
        }

        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: root.themeDark ? "#30ffffff" : "#20000000"
        }

        // 文件格式设置
        Text {
            text: "支持格式"
            color: root.textColor
            font.pixelSize: 15
            font.bold: true
        }

        Flow {
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: ["docx", "xlsx", "pptx", "txt"]
                delegate: Rectangle {
                    width: formatText.width + 24; height: 32
                    radius: 16
                    color: root.themeDark ? "#40ffffff" : "#40000000"
                    border.width: 1
                    border.color: root.themeDark ? "#60ffffff" : "#40000000"

                    Text {
                        id: formatText
                        anchors.centerIn: parent
                        text: modelData
                        color: root.textColor
                        font.pixelSize: 12
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
