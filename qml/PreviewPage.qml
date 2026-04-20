import QtQuick

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
    Item {
        id: topBar
        x: 0; y: 0
        width: parent.width; height: 40

        Rectangle {
            x: 0; anchors.verticalCenter: parent.verticalCenter
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
            x: 82; anchors.verticalCenter: parent.verticalCenter
            text: "纠错结果"
            color: root.textColor
            font.pixelSize: 16
            font.bold: true
        }

        // 统计标签 + 总数（右侧）
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

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
                anchors.verticalCenter: parent.verticalCenter
                text: "共 " + root.totalChanges + " 处"
                color: root.labelColor
                font.pixelSize: 12
            }
        }
    }

    // ============ 主内容（绝对定位）============
    Item {
        id: contentArea
        x: 0; y: topBar.height + 10
        width: parent.width
        height: parent.height - topBar.height - bottomBar.height - 20

        // 左侧：段落列表
        Rectangle {
            id: segPanel
            x: 0; y: 0
            width: 200; height: parent.height
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
                            width: 160
                        }
                        Text {
                            text: "段落 " + (modelData.seg_index + 1) + " · " + (modelData.changes ? modelData.changes.length : 0) + " 处修改"
                            color: root.labelColor
                            font.pixelSize: 10
                        }
                    }

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
            x: 212; y: 0
            width: parent.width - 212; height: parent.height
            radius: 12
            color: root.themeDark ? "#20ffffff" : "#10000000"

            // 原文标签
            Text {
                x: 12; y: 12
                text: "原文"
                color: root.labelColor
                font.pixelSize: 13
                font.bold: true
            }

            // 原文面板
            Rectangle {
                x: 12; y: 32
                width: (parent.width - 36) / 2; height: parent.height - 160
                radius: 8
                color: root.themeDark ? "#15ffffff" : "#08000000"

                Flickable {
                    anchors.fill: parent; anchors.margins: 8
                    contentHeight: origText.contentHeight; clip: true
                    TextEdit {
                        id: origText
                        width: parent.width
                        text: {
                            if (root.parsedResults.length > root.selectedSeg)
                                return root.parsedResults[root.selectedSeg].original_text || ""
                            return ""
                        }
                        color: root.textColor; font.pixelSize: 13
                        wrapMode: TextEdit.Wrap; readOnly: true; selectByMouse: true
                    }
                }
            }

            // 修正后标签
            Text {
                x: parent.width / 2 + 6; y: 12
                text: "修正后"
                color: root.labelColor
                font.pixelSize: 13
                font.bold: true
            }

            // 修正面板
            Rectangle {
                x: parent.width / 2 + 6; y: 32
                width: (parent.width - 36) / 2; height: parent.height - 160
                radius: 8
                color: root.themeDark ? "#15ffffff" : "#08000000"

                Flickable {
                    anchors.fill: parent; anchors.margins: 8
                    contentHeight: corrText.contentHeight; clip: true
                    TextEdit {
                        id: corrText
                        width: parent.width
                        text: {
                            if (root.parsedResults.length > root.selectedSeg)
                                return root.parsedResults[root.selectedSeg].corrected_text || ""
                            return ""
                        }
                        color: root.textColor; font.pixelSize: 13
                        wrapMode: TextEdit.Wrap; readOnly: true; selectByMouse: true
                    }
                }
            }

            // 改动详情标签
            Text {
                x: 12; y: parent.height - 120
                text: "改动详情"
                color: root.labelColor
                font.pixelSize: 13
                font.bold: true
            }

            // 改动详情列表
            Rectangle {
                x: 12; y: parent.height - 100
                width: parent.width - 24; height: 90
                radius: 8
                color: root.themeDark ? "#15ffffff" : "#08000000"

                ListView {
                    id: changesList
                    anchors.fill: parent; anchors.margins: 8
                    clip: true; spacing: 4
                    model: {
                        if (root.parsedResults.length > root.selectedSeg)
                            return root.parsedResults[root.selectedSeg].changes || []
                        return []
                    }

                    delegate: Rectangle {
                        width: changesList.width; height: 36; radius: 6
                        property var passColors: ({ "词典": "#50a0ff", "pycorrector": "#ff9040", "AI精校": "#50ff80" })
                        property color pColor: passColors[modelData.pass_name] || "#808080"
                        color: modelData.accepted ? Qt.rgba(pColor.r, pColor.g, pColor.b, 0.12) : (root.themeDark ? "#15ffffff" : "#08000000")
                        border.width: 1
                        border.color: modelData.accepted ? Qt.rgba(pColor.r, pColor.g, pColor.b, 0.3) : "transparent"

                        Row {
                            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            spacing: 8

                            Rectangle {
                                width: labelTxt.width + 10; height: 20; radius: 10
                                color: Qt.rgba(pColor.r, pColor.g, pColor.b, 0.2)
                                Text { id: labelTxt; anchors.centerIn: parent; text: modelData.pass_name; color: pColor; font.pixelSize: 10 }
                            }

                            Text {
                                width: changesList.width - 140; anchors.verticalCenter: parent.verticalCenter
                                text: modelData.original + " → " + modelData.corrected
                                color: root.textColor; font.pixelSize: 12; elide: Text.ElideRight
                            }
                        }

                        Row {
                            anchors.right: parent.right; anchors.rightMargin: 6; anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Rectangle {
                                width: 28; height: 24; radius: 4
                                color: acceptMouse.containsMouse ? "#3050ff80" : "transparent"
                                Text { anchors.centerIn: parent; text: "✓"; color: modelData.accepted ? "#50ff80" : root.labelColor; font.pixelSize: 14 }
                                MouseArea { id: acceptMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.acceptChange(root.selectedSeg, index) }
                            }
                            Rectangle {
                                width: 28; height: 24; radius: 4
                                color: rejectMouse.containsMouse ? "#30ff5050" : "transparent"
                                Text { anchors.centerIn: parent; text: "✕"; color: !modelData.accepted ? "#ff5050" : root.labelColor; font.pixelSize: 12 }
                                MouseArea { id: rejectMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.rejectChange(root.selectedSeg, index) }
                            }
                        }
                    }
                }
            }
        }
    }

    // ============ 底栏（绝对定位）============
    Item {
        id: bottomBar
        x: 0; y: parent.height - height
        width: parent.width; height: 42

        Row {
            x: 0; anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Rectangle {
                width: 80; height: 32; radius: 16
                color: acceptAllMouse.containsMouse ? "#3050ff80" : (root.themeDark ? "#30ffffff" : "#30000000")
                border.width: 1; border.color: root.themeDark ? "#40ffffff" : "#30000000"
                Text { anchors.centerIn: parent; text: "全部接受"; color: "#50ff80"; font.pixelSize: 12 }
                MouseArea { id: acceptAllMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.acceptAll() }
            }
            Rectangle {
                width: 80; height: 32; radius: 16
                color: rejectAllMouse.containsMouse ? "#30ff5050" : (root.themeDark ? "#30ffffff" : "#30000000")
                border.width: 1; border.color: root.themeDark ? "#40ffffff" : "#30000000"
                Text { anchors.centerIn: parent; text: "全部拒绝"; color: "#ff5050"; font.pixelSize: 12 }
                MouseArea { id: rejectAllMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.rejectAll() }
            }
        }

        Rectangle {
            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
            width: 100; height: 32; radius: 16
            color: exportMouse.containsMouse ? (root.themeDark ? "#60ffffff" : "#60000000") : (root.themeDark ? "#40ffffff" : "#40000000")
            border.width: 1; border.color: root.themeDark ? "#60ffffff" : "#40000000"
            Text { anchors.centerIn: parent; text: "📁 导出文件"; color: root.textColor; font.pixelSize: 12; font.bold: true }
            MouseArea { id: exportMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.exportClicked() }
        }
    }
}
