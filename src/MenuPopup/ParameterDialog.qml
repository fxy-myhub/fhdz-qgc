import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.12

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.FactSystem 1.0


/// @brief 全部参数弹窗
/// 标题 + 两栏布局（左侧分类列表 / 右侧参数列表）
/// 数据来源：ParameterEditorController（真实飞控参数）

Popup {
    id: parameterDialog
    width: ScreenTools.defaultFontPixelWidth * 130
    height: ScreenTools.defaultFontPixelHeight * 45
    modal: false
    closePolicy: Popup.CloseOnEscape
    padding: 0

    property var rootItem: null

    // 打开弹窗时强制重新读取参数，确保参数值正确显示
    onOpened: {
        controller.refresh()
    }

    QGCPalette { id: qgcPal }

    // ============ 主题模式（dayMode / nightMode）============
    property bool dayMode: qgcPal.globalTheme === QGCPalette.Light

    // 颜色常量（根据主题动态切换）
    readonly property color _bgColor:           dayMode ? "#F5F5F5" : "#1E1E1E"   // 弹窗主背景
    readonly property color _titleBarColor:     "#1976D2"                          // 标题栏背景（保持蓝色）
    readonly property color _headerColor:       dayMode ? "#E0E0E0" : "#333333"   // 表头背景
    readonly property color _rowEvenColor:      dayMode ? "#FFFFFF" : "#2A2A2A"   // 偶数行背景
    readonly property color _rowOddColor:       dayMode ? "#F5F5F5" : "#1E1E1E"   // 奇数行背景
    readonly property color _textColor:         dayMode ? "#000000" : "#FFFFFF"   // 文字颜色
    readonly property color _inputBgColor:      dayMode ? "#FFFFFF" : "#3A3A3A"   // 输入框背景
    readonly property color _btnBgColor:        "#1976D2"                          // 主按钮背景（保持蓝色）
    readonly property color _btnHoverColor:     "#1565C0"                          // 主按钮悬停（保持蓝色）
    readonly property color _cancelBgColor:     dayMode ? "#E0E0E0" : "#3A3A3A"   // 次按钮背景
    readonly property color _cancelHoverColor:  dayMode ? "#D0D0D0" : "#4A4A4A"   // 次按钮悬停
    readonly property color _borderColor:       dayMode ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(1, 1, 1, 0.15)  // 分隔线/边框
    readonly property color _selectedColor:     dayMode ? "#BBDEFB" : "#0D47A1"   // 左侧选中项背景

    // ============ 参数编辑器控制器 ============
    ParameterEditorController {
        id: controller
    }

    // 当前正在编辑的参数
    property Fact _editorDialogFact: Fact { }

    // 搜索过滤状态
    property bool _searchFilter: searchText.text.trim() != ""

    // ============ 编辑对话框组件 ============

    Component {
        id: editorDialogComponent

        ParameterEditorDialog {
            fact: _editorDialogFact
        }
    }


    background: Rectangle {
        color: _bgColor
        border.color: _borderColor
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        // ---- 标题栏（可拖拽） ----
        Rectangle {
            id: titleBar
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.2
            color: _titleBarColor
            // radius: 6

            // 只保留顶部圆角
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height - 6
                color: _titleBarColor
            }

            QGCLabel {
                anchors.centerIn: parent
                text: "全部参数"
                color: "#FFFFFF"
                font.bold: true
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelHeight
            }

            // 关闭按钮
            Rectangle {
                id: closeBtn
                anchors.right: parent.right
                anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 0.8
                anchors.verticalCenter: parent.verticalCenter
                width: ScreenTools.defaultFontPixelHeight * 1.7
                height: ScreenTools.defaultFontPixelHeight * 1.7
                color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : "transparent"

                QGCLabel {
                    anchors.centerIn: parent
                    text: "✕"
                    color: "#FFFFFF"
                    font.bold: true
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 1.3
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: parameterDialog.close()
                }
            }

            // 拖拽区域
            MouseArea {
                anchors.fill: parent
                anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 3
                cursorShape: Qt.OpenHandCursor
                property real _startX: 0
                property real _startY: 0
                onPressed: {
                    _startX = mouse.x
                    _startY = mouse.y
                }
                onPositionChanged: {
                    parameterDialog.x += mouse.x - _startX
                    parameterDialog.y += mouse.y - _startY
                }
            }
        }

        // ---- 搜索栏 ----
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.5
            Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.0
            Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.0
            spacing: ScreenTools.defaultFontPixelWidth

            QGCLabel {
                text: "搜索:"
                color: _textColor
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.75
            }

            QGCTextField {
                id: searchText
                Layout.fillWidth: true
                text: controller.searchText

                // 防抖定时器：停止输入 300ms 后才触发搜索
                Timer {
                    id: searchDebounceTimer
                    interval: 300
                    repeat: false
                    onTriggered: {
                        controller.searchText = searchText.displayText
                    }
                }

                onDisplayTextChanged: {
                    searchDebounceTimer.restart()
                }
            }


            QGCButton {
                text: "清除"
                onClicked: {
                    searchText.text = ""
                    controller.searchText = ""
                }
            }
        }

        // ---- 两栏主体区域 ----

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ============ 左侧栏：分类列表 ============
            Rectangle {
                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 22
                Layout.fillHeight: true
                color: _headerColor
                border.color: _borderColor
                border.width: 1
                visible: !_searchFilter

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // 分类标题
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.1
                        color: _headerColor

                        QGCLabel {
                            anchors.centerIn: parent
                            text: "分类"
                            color: _textColor
                            font.bold: true
                            font.family: "Microsoft YaHei"
                            font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                        }
                    }

                    // 分隔线
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: _borderColor
                    }

                    // 分类列表（可滚动）
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 0

                            Repeater {
                                model: controller.categories

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0

                                    // 分类标题（可点击展开/收起）
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.4
                                        color: (object === controller.currentCategory) ? _selectedColor : _headerColor

                                        // 展开/收起箭头
                                        QGCLabel {
                                            anchors.left: parent.left
                                            anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.8
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: (object === controller.currentCategory) ? "▼" : "▶"
                                            color: _textColor
                                            font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.6
                                        }

                                        // 分类名称
                                        QGCLabel {
                                            anchors.left: parent.left
                                            anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 2.2
                                            anchors.right: parent.right
                                            anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 0.5
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: object.name
                                            color: _textColor
                                            font.bold: true
                                            font.family: "Microsoft YaHei"
                                            font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                                            elide: Text.ElideRight
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                // 点击已选中的分类则折叠，点击其他分类则展开并选中
                                                if (object === controller.currentCategory) {
                                                    controller.currentCategory = null
                                                } else {
                                                    controller.currentCategory = object
                                                }
                                            }
                                        }
                                    }

                                    // 分类分隔线
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 1
                                        color: _borderColor
                                    }

                                    // 该分类下的参数组列表（仅选中分类展开）
                                    Repeater {
                                        model: (object === controller.currentCategory) ? object.groups : 0

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 0

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.2
                                                color: (object === controller.currentGroup) ? _selectedColor : _bgColor

                                                // 组名称（缩进显示）
                                                QGCLabel {
                                                    anchors.left: parent.left
                                                    anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 3.0
                                                    anchors.right: parent.right
                                                    anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 0.5
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: object.name
                                                    color: _textColor
                                                    font.bold: (object === controller.currentGroup)
                                                    font.family: "Microsoft YaHei"
                                                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.75
                                                    elide: Text.ElideRight
                                                }

                                                // 组选中指示条
                                                Rectangle {
                                                    anchors.left: parent.left
                                                    anchors.top: parent.top
                                                    anchors.bottom: parent.bottom
                                                    width: 3
                                                    color: (object === controller.currentGroup) ? _btnBgColor : "transparent"
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        controller.currentGroup = object
                                                    }
                                                }
                                            }

                                            // 参数组之间的分隔线
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 1
                                                color: _borderColor
                                            }
                                        }
                                    }

                                }
                            }
                        }
                    }


                }
            }

            // ============ 右侧栏：参数列表 ============

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: _bgColor

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // 表头
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.1
                        color: _headerColor

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.0
                            anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 1.0
                            spacing: ScreenTools.defaultFontPixelWidth * 0.7

                            QGCLabel {
                                text: "参数名"
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 22
                                color: _textColor
                                font.bold: true
                                font.family: "Microsoft YaHei"
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                                horizontalAlignment: Text.AlignHCenter
                            }
                            QGCLabel {
                                text: "参数值"
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 14
                                color: _textColor
                                font.bold: true
                                font.family: "Microsoft YaHei"
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                                horizontalAlignment: Text.AlignHCenter
                            }
                            QGCLabel {
                                text: "说明"
                                Layout.fillWidth: true
                                color: _textColor
                                font.bold: true
                                font.family: "Microsoft YaHei"
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    // 分隔线
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: _borderColor
                    }

                    // 参数列表（可滚动）
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 0

                            Repeater {
                                model: controller.parameters

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.2
                                    color: (index % 2 === 0) ? _rowEvenColor : _rowOddColor

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.0
                                        anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 1.0
                                        spacing: ScreenTools.defaultFontPixelWidth * 0.7

                                        // 参数名
                                        QGCLabel {
                                            text: object.name
                                            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 22
                                            color: _textColor
                                            font.bold: true
                                            font.family: "Microsoft YaHei"
                                            font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.75
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                        }

                                        // 参数值
                                        QGCLabel {
                                            text: {
                                                if (object.enumStrings.length === 0) {
                                                    return object.valueString + (object.units !== "" ? " " + object.units : "")
                                                }
                                                return object.enumStringValue
                                            }
                                            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 14
                                            color: object.defaultValueAvailable && !object.valueEqualsDefault ? qgcPal.warningText : _textColor
                                            font.family: "Microsoft YaHei"
                                            font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.75
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                        }

                                        // 说明
                                        QGCLabel {
                                            text: object.shortDescription
                                            Layout.fillWidth: true
                                            color: _textColor
                                            font.family: "Microsoft YaHei"
                                            font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.75
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // 点击行弹出编辑对话框
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            _editorDialogFact = object
                                            mainWindow.showComponentDialog(editorDialogComponent, qsTr("参数编辑"), mainWindow.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Save)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
    }

}



