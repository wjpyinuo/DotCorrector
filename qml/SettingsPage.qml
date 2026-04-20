import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool themeDark: true
    property color labelColor: "#c0ffffff"
    property color textColor: "white"
    property color bgColor: "#2a2e5a"

    // 设置绑定
    property bool useDict: true
    property bool usePycorrector: true
    property bool useLlm: false
    property string apiKey: ""

    signal back()
    signal dictToggled(bool value)
    signal pycorrectorToggled(bool value)
    signal llmToggled(bool value)
    signal apiKeyUpdated(string value)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // 返回按钮 + 标题
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

        // 纠错引擎
        Text {
            text: "纠错引擎"
            color: root.textColor
            font.pixelSize: 15
            font.bold: true
        }

        // 本地纠错
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ToggleSwitch {
                id: localToggle
                checked: root.useDict && root.usePycorrector
                dark: root.themeDark
                onCheckedChanged: {
                    root.dictToggled(checked)
                    root.pycorrectorToggled(checked)
                }
            }
            Column {
                Text { text: "本地纠错（免费）"; color: root.textColor; font.pixelSize: 13; font.bold: true }
                Text { text: "错别字词典 + pycorrector，无需联网"; color: root.labelColor; font.pixelSize: 11 }
            }
            Item { Layout.fillWidth: true }
        }

        // AI 精校
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ToggleSwitch {
                id: aiToggle
                checked: root.useLlm
                dark: root.themeDark
                onCheckedChanged: root.llmToggled(checked)
            }
            Column {
                Text { text: "AI 精校（需 API Key）"; color: root.textColor; font.pixelSize: 13; font.bold: true }
                Text { text: "调用大模型 API，纠错精度更高"; color: root.labelColor; font.pixelSize: 11 }
            }
            Item { Layout.fillWidth: true }
        }

        // API Key 输入
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
                    text: root.apiKey
                    onTextChanged: root.apiKeyUpdated(text)
                }

                Text {
                    anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                    text: "输入你的 MiMo API Key..."
                    color: root.themeDark ? "#60ffffff" : "#60000000"
                    font.pixelSize: 12
                    visible: apiKeyInput.text.length === 0 && !apiKeyInput.activeFocus
                }
            }
        }

        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: root.themeDark ? "#30ffffff" : "#20000000"
        }

        // 支持格式
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

        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: root.themeDark ? "#30ffffff" : "#20000000"
        }

        // 纠错流程说明
        Text {
            text: "纠错流程"
            color: root.textColor
            font.pixelSize: 15
            font.bold: true
        }

        Column {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    {step: "1", name: "错别字词典", desc: "常见同音字、形近字匹配替换", color: "#50a0ff"},
                    {step: "2", name: "pycorrector", desc: "基于统计模型的上下文纠错", color: "#ff9040"},
                    {step: "3", name: "AI 精校", desc: "大模型语义级纠错和润色", color: "#50ff80"}
                ]

                delegate: RowLayout {
                    width: parent.width
                    spacing: 10

                    Rectangle {
                        width: 24; height: 24; radius: 12
                        color: modelData.color
                        Text {
                            anchors.centerIn: parent
                            text: modelData.step
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }

                    Column {
                        Text { text: modelData.name; color: root.textColor; font.pixelSize: 12; font.bold: true }
                        Text { text: modelData.desc; color: root.labelColor; font.pixelSize: 10 }
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
