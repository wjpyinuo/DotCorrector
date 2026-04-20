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
    property string apiProvider: "mimo"
    property string apiBase: ""

    signal back()
    signal dictToggled(bool value)
    signal pycorrectorToggled(bool value)
    signal llmToggled(bool value)
    signal apiKeyUpdated(string value)
    signal apiProviderUpdated(string value)
    signal apiBaseUpdated(string value)

    Flickable {
        id: flick
        anchors.fill: parent
        contentHeight: contentCol.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: contentCol
            width: flick.width
            spacing: 16

            // 返回按钮 + 标题
            Row {
                spacing: 8
                Layout.fillWidth: true
                Layout.bottomMargin: 4

                Rectangle {
                    width: 72; height: 30; radius: 15
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

            // ========== 纠错引擎 ==========
            Text {
                text: "纠错引擎"
                color: root.textColor
                font.pixelSize: 15
                font.bold: true
                Layout.bottomMargin: -4
            }

            // 本地纠错 - 词典
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ToggleSwitch {
                    id: dictToggle
                    checked: root.useDict
                    dark: root.themeDark
                    onCheckedChanged: root.dictToggled(checked)
                }
                Column {
                    Text { text: "错别字词典"; color: root.textColor; font.pixelSize: 13; font.bold: true }
                    Text { text: "200+ 常见同音字、形近字匹配，极快"; color: root.labelColor; font.pixelSize: 11 }
                }
                Item { Layout.fillWidth: true }
            }

            // 本地纠错 - pycorrector
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ToggleSwitch {
                    id: pycToggle
                    checked: root.usePycorrector
                    dark: root.themeDark
                    onCheckedChanged: root.pycorrectorToggled(checked)
                }
                Column {
                    Text { text: "pycorrector 统计模型"; color: root.textColor; font.pixelSize: 13; font.bold: true }
                    Text { text: "上下文语法纠错，无需联网"; color: root.labelColor; font.pixelSize: 11 }
                }
                Item { Layout.fillWidth: true }
            }

            // 分隔线
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: root.themeDark ? "#20ffffff" : "#15000000"
            }

            // ========== AI 精校 ==========
            Text {
                text: "AI 精校"
                color: root.textColor
                font.pixelSize: 15
                font.bold: true
                Layout.bottomMargin: -4
            }

            // AI 总开关
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
                    Text { text: "启用 AI 精校"; color: root.textColor; font.pixelSize: 13; font.bold: true }
                    Text { text: "调用大模型 API，语义级纠错精度更高"; color: root.labelColor; font.pixelSize: 11 }
                }
                Item { Layout.fillWidth: true }
            }

            // AI 配置区（开关打开时显示）
            ColumnLayout {
                visible: aiToggle.checked
                Layout.fillWidth: true
                Layout.leftMargin: 8
                spacing: 12

                // API 服务商选择
                Text {
                    text: "API 服务商"
                    color: root.labelColor
                    font.pixelSize: 12
                    font.bold: true
                }

                Row {
                    spacing: 10

                    Repeater {
                        model: [
                            {id: "mimo", name: "MiMo", desc: "小米大模型", color: "#ff6a00"},
                            {id: "deepseek", name: "DeepSeek", desc: "深度求索", color: "#50a0ff"}
                        ]

                        delegate: Rectangle {
                            width: providerCol.width + 24
                            height: 56
                            radius: 10
                            property bool selected: root.apiProvider === modelData.id
                            color: selected ? Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.15) : (root.themeDark ? "#15ffffff" : "#08000000")
                            border.width: selected ? 1.5 : 1
                            border.color: selected ? modelData.color : (root.themeDark ? "#30ffffff" : "#20000000")
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            Column {
                                id: providerCol
                                anchors.centerIn: parent
                                spacing: 2

                                Row {
                                    spacing: 6
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Rectangle {
                                        width: 8; height: 8; radius: 4
                                        color: modelData.color
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.name
                                        color: root.textColor
                                        font.pixelSize: 13
                                        font.bold: true
                                    }
                                }
                                Text {
                                    text: modelData.desc
                                    color: root.labelColor
                                    font.pixelSize: 10
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.apiProviderUpdated(modelData.id)
                            }
                        }
                    }
                }

                // 分隔
                Rectangle {
                    Layout.fillWidth: true; height: 1
                    Layout.topMargin: 4
                    color: root.themeDark ? "#15ffffff" : "#10000000"
                }

                // API Key 输入
                Text {
                    text: root.apiProvider === "mimo" ? "MiMo API Key" : "DeepSeek API Key"
                    color: root.labelColor
                    font.pixelSize: 12
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 8
                    color: root.themeDark ? "#40ffffff" : "#40000000"
                    border.width: 1
                    border.color: root.themeDark ? "#60ffffff" : "#40000000"

                    TextInput {
                        id: apiKeyInput
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: root.textColor
                        font.pixelSize: 12
                        clip: true
                        echoMode: TextInput.Password
                        text: root.apiKey
                        onTextChanged: root.apiKeyUpdated(text)
                    }

                    Text {
                        anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                        text: root.apiProvider === "mimo"
                            ? "粘贴 MiMo API Key..."
                            : "粘贴 DeepSeek API Key..."
                        color: root.themeDark ? "#60ffffff" : "#60000000"
                        font.pixelSize: 12
                        visible: apiKeyInput.text.length === 0 && !apiKeyInput.activeFocus
                    }
                }

                // API 地址（可自定义）
                Text {
                    text: "API Base URL"
                    color: root.labelColor
                    font.pixelSize: 12
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 8
                    color: root.themeDark ? "#40ffffff" : "#40000000"
                    border.width: 1
                    border.color: root.themeDark ? "#60ffffff" : "#40000000"

                    TextInput {
                        id: apiBaseInput
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: root.textColor
                        font.pixelSize: 12
                        clip: true
                        text: root.apiBase
                        onTextChanged: root.apiBaseUpdated(text)
                    }

                    Text {
                        anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                        text: root.apiProvider === "mimo"
                            ? "https://api.mimo.ai/v1"
                            : "https://api.deepseek.com/v1"
                        color: root.themeDark ? "#60ffffff" : "#60000000"
                        font.pixelSize: 12
                        visible: apiBaseInput.text.length === 0 && !apiBaseInput.activeFocus
                    }
                }
            }

            // 分隔线
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: root.themeDark ? "#20ffffff" : "#15000000"
            }

            // ========== 支持格式 ==========
            Text {
                text: "支持格式"
                color: root.textColor
                font.pixelSize: 15
                font.bold: true
                Layout.bottomMargin: -4
            }

            Flow {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: [
                        {ext: "docx", icon: "📄", desc: "Word"},
                        {ext: "xlsx", icon: "📊", desc: "Excel"},
                        {ext: "pptx", icon: "📑", desc: "PowerPoint"},
                        {ext: "txt", icon: "📝", desc: "纯文本"}
                    ]
                    delegate: Rectangle {
                        width: fmtContent.width + 20; height: 32; radius: 16
                        color: root.themeDark ? "#40ffffff" : "#40000000"
                        border.width: 1
                        border.color: root.themeDark ? "#60ffffff" : "#40000000"

                        Row {
                            id: fmtContent
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: modelData.icon; font.pixelSize: 13 }
                            Text { text: modelData.ext; color: root.textColor; font.pixelSize: 12 }
                            Text { text: "(" + modelData.desc + ")"; color: root.labelColor; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }
            }

            // 分隔线
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: root.themeDark ? "#20ffffff" : "#15000000"
            }

            // ========== 纠错流程 ==========
            Text {
                text: "纠错流程"
                color: root.textColor
                font.pixelSize: 15
                font.bold: true
                Layout.bottomMargin: -4
            }

            Column {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: [
                        {step: "1", name: "错别字词典", desc: "200+ 常见同音字、形近字匹配替换", color: "#50a0ff", enabled: root.useDict},
                        {step: "2", name: "pycorrector", desc: "统计模型 + 规则的上下文纠错", color: "#ff9040", enabled: root.usePycorrector},
                        {step: "3", name: "AI 精校", desc: "MiMo / DeepSeek 大模型语义级纠错", color: "#50ff80", enabled: root.useLlm}
                    ]

                    delegate: RowLayout {
                        width: parent.width
                        spacing: 10
                        opacity: modelData.enabled ? 1.0 : 0.35

                        Rectangle {
                            width: 26; height: 26; radius: 13
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
                            Layout.fillWidth: true
                            spacing: 2
                            Text { text: modelData.name; color: root.textColor; font.pixelSize: 12; font.bold: true }
                            Text { text: modelData.desc; color: root.labelColor; font.pixelSize: 10; wrapMode: Text.Wrap; width: parent.width }
                        }

                        // 启用状态指示
                        Text {
                            text: modelData.enabled ? "✓" : "—"
                            color: modelData.enabled ? modelData.color : root.labelColor
                            font.pixelSize: 14
                        }
                    }
                }
            }

            // 底部留白
            Item { Layout.fillHeight: true; Layout.minimumHeight: 20 }
        }
    }
}
