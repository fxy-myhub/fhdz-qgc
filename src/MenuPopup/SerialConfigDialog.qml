import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

/// @brief 串口功能配置弹窗
/// 标题 + 表头(串口号/波特率/设备/连接状态) + 8行串口配置
/// 支持白天/夜间主题切换
Popup {
    id: serialConfigDialog

    width: ScreenTools.defaultFontPixelWidth * 95
    height: ScreenTools.defaultFontPixelHeight * 22
    modal: false
    closePolicy: Popup.CloseOnEscape
    padding: 0

    property var rootItem: null

    QGCPalette { id: qgcPal }

    // ============ 主题模式（dayMode / nightMode）============
    // 通过 qgcPal.globalTheme 判断：Light = 白天模式，Dark = 夜间模式
    property bool dayMode: qgcPal.globalTheme === QGCPalette.Light

    // 颜色常量（根据主题动态切换）
    readonly property color _bgColor:           dayMode ? "#F5F5F5" : "#1E1E1E"   // 弹窗主背景
    readonly property color _titleBarColor:     "#1976D2"                          // 标题栏背景（保持蓝色）
    readonly property color _headerColor:       dayMode ? "#E0E0E0" : "#333333"   // 表头背景
    readonly property color _rowEvenColor:      dayMode ? "#FFFFFF" : "#2A2A2A"   // 偶数行背景
    readonly property color _rowOddColor:       dayMode ? "#F5F5F5" : "#1E1E1E"   // 奇数行背景
    readonly property color _textColor:         dayMode ? "#000000" : "#FFFFFF"   // 文字颜色
    readonly property color _inputBgColor:      dayMode ? "#FFFFFF" : "#3A3A3A"   // 输入框背景
    readonly property color _borderColor:       dayMode ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(1, 1, 1, 0.15)  // 分隔线/边框

    // 波特率选项
    property var _baudRateOptions: [
        "9600", "19200", "38400", "57600",
        "115200", "230400", "460800", "921600"
    ]

    // 设备选项
    property var _deviceOptions: [
        "GPS", "数传", "图传", "遥控", "传感器", "其他"
    ]

    // 串口数据模型（8行：uart1 ~ uart8）
    property var _serialData: [
        { port: "uart1", baud: 4, device: 0, status: "未连接" },
        { port: "uart2", baud: 4, device: 0, status: "未连接" },
        { port: "uart3", baud: 4, device: 0, status: "未连接" },
        { port: "uart4", baud: 4, device: 0, status: "未连接" },
        { port: "uart5", baud: 4, device: 0, status: "未连接" },
        { port: "uart6", baud: 4, device: 0, status: "未连接" },
        { port: "uart7", baud: 4, device: 0, status: "未连接" },
        { port: "uart8", baud: 4, device: 0, status: "未连接" }
    ]

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
            radius: 6

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
                text: "串口功能配置"
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
                    onClicked: serialConfigDialog.close()
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
                    serialConfigDialog.x += mouse.x - _startX
                    serialConfigDialog.y += mouse.y - _startY
                }
            }
        }

        // ---- 表头 ----
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
                    text: "串口号"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 12
                    color: _textColor
                    font.bold: true
                    font.family: "Microsoft YaHei"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                    horizontalAlignment: Text.AlignHCenter
                }
                QGCLabel {
                    text: "波特率"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 14
                    color: _textColor
                    font.bold: true
                    font.family: "Microsoft YaHei"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                    horizontalAlignment: Text.AlignHCenter
                }
                QGCLabel {
                    text: "设备"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 14
                    color: _textColor
                    font.bold: true
                    font.family: "Microsoft YaHei"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                    horizontalAlignment: Text.AlignHCenter
                }
                QGCLabel {
                    text: "连接状态"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 14
                    color: _textColor
                    font.bold: true
                    font.family: "Microsoft YaHei"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                    horizontalAlignment: Text.AlignHCenter
                }
                QGCLabel {
                    text: "操作"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 12
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

        // ---- 串口配置列表 ----
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Repeater {
                model: 8

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.2
                    color: (index % 2 === 0) ? _rowEvenColor : _rowOddColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.0
                        anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 1.0
                        spacing: ScreenTools.defaultFontPixelWidth * 0.7

                        // 串口号
                        QGCLabel {
                            text: _serialData[index].port
                            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 12
                            color: _textColor
                            font.bold: true
                            font.family: "Microsoft YaHei"
                            font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        // 波特率下拉框
                        QGCComboBox {
                            id: baudCombo
                            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 14
                            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
                            font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                            font.bold: true
                            model: _baudRateOptions
                            currentIndex: _serialData[index].baud
                            popup.parent: Overlay.overlay
                            popup.onOpened: {
                                var globalPos = baudCombo.mapToGlobal(0, baudCombo.height)
                                var overlayPos = Overlay.overlay.mapFromGlobal(globalPos.x, globalPos.y)
                                popup.x = overlayPos.x
                                popup.y = overlayPos.y
                                popup.z = serialConfigDialog.z + 10
                            }
                            onActivated: {
                                _serialData[index].baud = index
                            }
                            // 下拉列表选项项（悬停变色）
                            delegate: ItemDelegate {
                                width: baudCombo.popup.width
                                highlighted: baudCombo.highlightedIndex === index
                                contentItem: Text {
                                    text: modelData
                                    color: hovered ? "#1976D2" : _textColor
                                    font.bold: true
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    color: hovered ? (dayMode ? "#E3F2FD" : "#1E3A5F") : (dayMode ? "#FFFFFF" : "#2A2A2A")
                                }
                            }
                        }

                        // 设备下拉框
                        QGCComboBox {
                            id: deviceCombo
                            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 14
                            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
                            font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                            font.bold: true
                            model: _deviceOptions
                            currentIndex: _serialData[index].device
                            popup.parent: Overlay.overlay
                            popup.onOpened: {
                                var globalPos = deviceCombo.mapToGlobal(0, deviceCombo.height)
                                var overlayPos = Overlay.overlay.mapFromGlobal(globalPos.x, globalPos.y)
                                popup.x = overlayPos.x
                                popup.y = overlayPos.y
                                popup.z = serialConfigDialog.z + 10
                            }
                            onActivated: {
                                _serialData[index].device = index
                            }
                            // 下拉列表选项项（悬停变色）
                            delegate: ItemDelegate {
                                width: deviceCombo.popup.width
                                highlighted: deviceCombo.highlightedIndex === index
                                contentItem: Text {
                                    text: modelData
                                    color: hovered ? "#1976D2" : _textColor
                                    font.bold: true
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    color: hovered ? (dayMode ? "#E3F2FD" : "#1E3A5F") : (dayMode ? "#FFFFFF" : "#2A2A2A")
                                }
                            }
                        }

                        // 连接状态（预留）
                        QGCLabel {
                            text: _serialData[index].status
                            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 14
                            color: _textColor
                            font.bold: true
                            font.family: "Microsoft YaHei"
                            font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        // 确定按钮
                        Rectangle {
                            id: confirmBtn
                            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
                            color: confirmMouse.containsMouse ? "#1565C0" : "#1976D2"

                            QGCLabel {
                                anchors.centerIn: parent
                                text: "确定"
                                color: "#FFFFFF"
                                font.bold: true
                                font.family: "Microsoft YaHei"
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.7
                            }

                            MouseArea {
                                id: confirmMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    console.log("确定串口" + _serialData[index].port + "配置")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
