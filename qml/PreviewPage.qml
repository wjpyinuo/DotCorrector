import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool themeDark: true
    property color textColor: "white"
    property color labelColor: "#b0ffffff"
    property color bgColor: "#2a2e5a"
    property string resultsJson: "[]"
    property int totalChanges: 0
    property int dictChanges: 0
    property int pycChanges: 0
    property int llmChanges: 0

    signal back()
    signal exportClicked()
    signal acceptChange(int segIndex, int changeIndex)
    signal rejectChange(int segIndex, int changeIndex)
    signal acceptAll()
    signal rejectAll()

    property var parsedResults: {
        try { return JSON.parse(resultsJson) }
        catch(e) { return [] }
    }

    property int selectedSeg: 0

    // ============ 顶栏 ============
    RowLayout {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 40
        spacing: 12

        Rectangle {
            width: 72; height: 30; radius: 15
            color: backMouse.containsMouse ? (root.themeDark ? "#60ffffff" : "#60000000") : (root.themeDark ? "#30ffffff" : "#30000000")
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
            text: "纠错结果"
            color: root.textColor
            font.pixelSize: 16
            font.bold: true
        }

        Item { Layout.fillWidth: true }

        // 统计标签
        Repeater {
            model: [
                {label: "词典", count: root.dictChanges, color: "#50a0ff"},
                {label: "pycorrector", count: root.pycChanges, color: "#ff9040"},
                {label: "AI精校", count: root.llmChanges, color: "#50ff80"}
            ]
            delegate: Rectangle {
                visible: modelData.count > 0
                width: statText.width + 16; height: 24; radius: 12
                color: Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.2)
                border.width: 1
                border.color: Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.5)

                Text {
                    id: statText
                    anchors.centerIn: parent
                    text: modelData.label + " " + modelData.count
                    color: modelData.color
                    font.pixelSize: 11
                }
            }
        }

        Text {
            text: "共 " + root.totalChanges + " 处"
            color: root.labelColor
            font.pixelSize: 12
        }
    }

    // ============ 主内容 ============
    RowLayout {
        anchors { top: topBar.bottom; bottom: bottomBar.top; left: parent.left; right: parent.right; topMargin: 10; bottomMargin: 10 }
        spacing: 12

        // 左侧：段落列表
        Rectangle {
            Layout.preferredWidth: 200
            Layout.fillHeight: true
            radius: 12
            color: root.themeDark ? "#20ffffff" : "#10000000"

            ListView {
                id: segList
                anchors.fill: parent
                anchors.margins: 6
                clip: true
                model: root.parsedResults
                spacing: 4

                delegate: Rectangle {
                    width: segList.width - 12
                    height: 48
                    radius: 8
                    x: 6
                    color: root.selectedSeg === index ? (root.themeDark ? "#40ffffff" : "#40000000") : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Column {
                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                        spacing: 2

                        Text {
                            text: modelData.file || "文件"
                            color: root.textColor
                            font.pixelSize: 12
                            font.bold: true
                            elide: Text.ElideRight
                            width: parent.parent.width - 20
                        }
                        Text {
                            text: "段落 " + (modelData.seg_index + 1) + " · " + (modelData.changes ? modelData.changes.length : 0) + " 处修改"
                            color: root.labelColor
                            font.pixelSize: 10
                        }
                    }

                    // 修改指示点
                    Rectangle {
                        anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                        width: 8; height: 8; radius: 4
                        visible: modelData.changes && modelData.changes.length > 0
                        color: "#50ff80"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectedSeg = index
                    }
                }
            }
        }

        // 右侧：对比视图
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: root.themeDark ? "#20ffffff" : "#10000000"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                // 原文 vs 修正
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    // 原文面板
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6

                        Text {
                            text: "原文"
                            color: root.labelColor
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: root.themeDark ? "#15ffffff" : "#08000000"

                            Flickable {
                                anchors.fill: parent
                                anchors.margins: 8
                                contentHeight: origText.contentHeight
                                clip: true

                                TextEdit {
                                    id: origText
                                    width: parent.width
                                    text: {
                                        if (root.parsedResults.length > root.selectedSeg)
                                            return root.parsedResults[root.selectedSeg].original_text || ""
                                        return ""
                                    }
                                    color: root.textColor
                                    font.pixelSize: 13
                                    wrapMode: TextEdit.Wrap
                                    readOnly: true
                                    selectByMouse: true
                                }
                            }
                        }
                    }

                    // 修正面板
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6

                        Text {
                            text: "修正后"
                            color: root.labelColor
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: root.themeDark ? "#15ffffff" : "#08000000"

                            Flickable {
                                anchors.fill: parent
                                anchors.margins: 8
                                contentHeight: corrText.contentHeight
                                clip: true

                                TextEdit {
                                    id: corrText
                                    width: parent.width
                                    text: {
                                        if (root.parsedResults.length > root.selectedSeg)
                                            return root.parsedResults[root.selectedSeg].corrected_text || ""
                                        return ""
                                    }
                                    color: root.textColor
                                    font.pixelSize: 13
                                    wrapMode: TextEdit.Wrap
                                    readOnly: true
                                    selectByMouse: true
                                }
                            }
                        }
                    }
                }

                // 改动详情列表
                Text {
                    text: "改动详情"
                    color: root.labelColor
                    font.pixelSize: 13
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(changesList.contentHeight + 16, 200)
                    radius: 8
                    color: root.themeDark ? "#15ffffff" : "#08000000"

                    ListView {
                        id: changesList
                        anchors.fill: parent
                        anchors.margins: 8
                        clip: true
                        spacing: 4
                        model: {
                            if (root.parsedResults.length > root.selectedSeg)
                                return root.parsedResults[root.selectedSeg].changes || []
                            return []
                        }

                        delegate: Rectangle {
                            width: changesList.width
                            height: 36
                            radius: 6

                            property var passColors: ({
                                "词典": "#50a0ff",
                                "pycorrector": "#ff9040",
                                "AI精校": "#50ff80"
                            })
                            property color pColor: passColors[modelData.pass_name] || "#808080"

                            color: modelData.accepted ? Qt.rgba(pColor.r, pColor.g, pColor.b, 0.12) : (root.themeDark ? "#15ffffff" : "#08000000")
                            border.width: 1
                            border.color: modelData.accepted ? Qt.rgba(pColor.r, pColor.g, pColor.b, 0.3) : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 6
                                spacing: 8

                                // 来源标签
                                Rectangle {
                                    width: labelTxt.width + 10; height: 20; radius: 10
                                    color: Qt.rgba(pColor.r, pColor.g, pColor.b, 0.2)
                                    Text {
                                        id: labelTxt
                                        anchors.centerIn: parent
                                        text: modelData.pass_name
                                        color: pColor
                                        font.pixelSize: 10
                                    }
                                }

                                // 改动内容
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.original + " → " + modelData.corrected
                                    color: root.textColor
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }

                                // 接受/拒绝按钮
                                Rectangle {
                                    width: 28; height: 24; radius: 4
                                    color: acceptMouse.containsMouse ? "#3050ff80" : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        color: modelData.accepted ? "#50ff80" : root.labelColor
                                        font.pixelSize: 14
                                    }
                                    MouseArea {
                                        id: acceptMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.acceptChange(root.selectedSeg, index)
                                    }
                                }

                                Rectangle {
                                    width: 28; height: 24; radius: 4
                                    color: rejectMouse.containsMouse ? "#30ff5050" : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✕"
                                        color: !modelData.accepted ? "#ff5050" : root.labelColor
                                        font.pixelSize: 12
                                    }
                                    MouseArea {
                                        id: rejectMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.rejectChange(root.selectedSeg, index)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ============ 底栏 ============
    RowLayout {
        id: bottomBar
        anchors { bottom: parent.bottom; bottomMargin: 4; left: parent.left; right: parent.right }
        height: 42
        spacing: 10

        // 全部接受
        Rectangle {
            width: 80; height: 32; radius: 16
            color: acceptAllMouse.containsMouse ? "#3050ff80" : (root.themeDark ? "#30ffffff" : "#30000000")
            border.width: 1
            border.color: root.themeDark ? "#40ffffff" : "#30000000"
            Text {
                anchors.centerIn: parent
                text: "全部接受"
                color: "#50ff80"
                font.pixelSize: 12
            }
            MouseArea {
                id: acceptAllMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.acceptAll()
            }
        }

        // 全部拒绝
        Rectangle {
            width: 80; height: 32; radius: 16
            color: rejectAllMouse.containsMouse ? "#30ff5050" : (root.themeDark ? "#30ffffff" : "#30000000")
            border.width: 1
            border.color: root.themeDark ? "#40ffffff" : "#30000000"
            Text {
                anchors.centerIn: parent
                text: "全部拒绝"
                color: "#ff5050"
                font.pixelSize: 12
            }
            MouseArea {
                id: rejectAllMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.rejectAll()
            }
        }

        Item { Layout.fillWidth: true }

        // 导出按钮
        Rectangle {
            width: 100; height: 32; radius: 16
            color: exportMouse.containsMouse ? (root.themeDark ? "#60ffffff" : "#60000000") : (root.themeDark ? "#40ffffff" : "#40000000")
            border.width: 1
            border.color: root.themeDark ? "#60ffffff" : "#40000000"
            Text {
                anchors.centerIn: parent
                text: "📁 导出文件"
                color: root.textColor
                font.pixelSize: 12
                font.bold: true
            }
            MouseArea {
                id: exportMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.exportClicked()
            }
        }
    }
}
