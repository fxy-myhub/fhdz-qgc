import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

/// @brief PWM通道配置弹窗
/// 标题 + 表头(通道号/PWM当前值/功能/最小值/中间值/最大值) + 16行通道配置
/// 支持白天/夜间主题切换
Popup {
    id: pwmConfigDialog

    width: ScreenTools.defaultFontPixelWidth * 120
    height: ScreenTools.defaultFontPixelHeight * 40
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
    readonly property color _btnBgColor:        "#1976D2"                          // 确认按钮背景（保持蓝色）
    readonly property color _btnHoverColor:     "#1565C0"                          // 确认按钮悬停（保持蓝色）
    readonly property color _cancelBgColor:     dayMode ? "#E0E0E0" : "#3A3A3A"   // 取消按钮背景
    readonly property color _cancelHoverColor:  dayMode ? "#D0D0D0" : "#4A4A4A"   // 取消按钮悬停
    readonly property color _borderColor:       dayMode ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(1, 1, 1, 0.15)  // 分隔线/边框


    // 通道功能选项
    property var _functionOptions: [
        "无", "副翼", "升降舵", "油门", "方向舵",
        "襟翼", "起落架", "辅助1", "辅助2", "辅助3",
        "辅助4", "辅助5", "辅助6", "辅助7", "辅助8"
    ]

    // 通道数据模型
    property var _channelData: [
        { channel: 1,  pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 2,  pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 3,  pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 4,  pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 5,  pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 6,  pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 7,  pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 8,  pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 9,  pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 10, pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 11, pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 12, pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 13, pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 14, pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 15, pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false },
        { channel: 16, pwm: 1500, func: 0, min: 1000, mid: 1500, max: 2000, reverse: false }
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
                text: "PWM通道配置"
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
                    onClicked: pwmConfigDialog.close()
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
                    pwmConfigDialog.x += mouse.x - _startX
                    pwmConfigDialog.y += mouse.y - _startY
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
                    text: "通道号"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7
                    color: _textColor
                    font.bold: true
                    font.family: "Microsoft YaHei"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                    horizontalAlignment: Text.AlignHCenter
                }
                QGCLabel {
                    text: "PWM当前值"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 9
                    color: _textColor
                    font.bold: true
                    font.family: "Microsoft YaHei"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                    horizontalAlignment: Text.AlignHCenter
                }
                QGCLabel {
                    text: "功能"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                    color: _textColor
                    font.bold: true
                    font.family: "Microsoft YaHei"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                    horizontalAlignment: Text.AlignHCenter
                }
                QGCLabel {
                    text: "最小值"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    color: _textColor
                    font.bold: true
                    font.family: "Microsoft YaHei"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                    horizontalAlignment: Text.AlignHCenter
                }
                QGCLabel {
                    text: "中间值"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    color: _textColor
                    font.bold: true
                    font.family: "Microsoft YaHei"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                    horizontalAlignment: Text.AlignHCenter
                }
                QGCLabel {
                    text: "最大值"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    color: _textColor
                    font.bold: true
                    font.family: "Microsoft YaHei"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                    horizontalAlignment: Text.AlignHCenter
                }
                QGCLabel {
                    text: "反向"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    color: _textColor
                    font.bold: true
                    font.family: "Microsoft YaHei"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                    horizontalAlignment: Text.AlignHCenter
                }
                QGCLabel {
                    text: "操作"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
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

        // ---- 通道配置列表（可滚动） ----
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 0

                Repeater {
                    model: 16

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.2
                        color: (index % 2 === 0) ? _rowEvenColor : _rowOddColor

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.0
                            anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 1.0
                            spacing: ScreenTools.defaultFontPixelWidth * 0.7

                            // 通道号
                            QGCLabel {
                                text: "CH" + (index + 1)
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7
                                color: _textColor
                                font.bold: true
                                font.family: "Microsoft YaHei"
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            // PWM当前值
                            QGCLabel {
                                text: _channelData[index].pwm
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 9
                                color: _textColor
                                font.bold: true
                                font.family: "Microsoft YaHei"
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            // 功能下拉框
                            QGCComboBox {
                                id: functionCombo
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                                font.bold: true
                                sizeToContents: true
                                model: _functionOptions
                                currentIndex: _channelData[index].func
                                popup.parent: Overlay.overlay
                                popup.onOpened: {
                                    var globalPos = functionCombo.mapToGlobal(0, functionCombo.height)
                                    var overlayPos = Overlay.overlay.mapFromGlobal(globalPos.x, globalPos.y)
                                    popup.x = overlayPos.x
                                    popup.y = overlayPos.y
                                    popup.z = pwmConfigDialog.z + 10
                                }
                                onActivated: {
                                    _channelData[index].func = index
                                }
                            }

                            // 最小值
                            TextField {
                                id: minField
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
                                text: _channelData[index].min
                                color: _textColor
                                font.bold: true
                                font.family: "Microsoft YaHei"
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                padding: 0
                                leftPadding: 0
                                rightPadding: 0
                                background: Rectangle {
                                    color: _inputBgColor
                                    border.color: _borderColor
                                    border.width: 1
                                }
                                validator: IntValidator { bottom: 500; top: 2500 }
                                onTextChanged: {
                                    var val = parseInt(text)
                                    if (!isNaN(val)) _channelData[index].min = val
                                }
                            }

                            // 中间值
                            TextField {
                                id: midField
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
                                text: _channelData[index].mid
                                color: _textColor
                                font.bold: true
                                font.family: "Microsoft YaHei"
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                padding: 0
                                leftPadding: 0
                                rightPadding: 0
                                background: Rectangle {
                                    color: _inputBgColor
                                    border.color: _borderColor
                                    border.width: 1
                                }
                                validator: IntValidator { bottom: 500; top: 2500 }
                                onTextChanged: {
                                    var val = parseInt(text)
                                    if (!isNaN(val)) _channelData[index].mid = val
                                }
                            }

                            // 最大值
                            TextField {
                                id: maxField
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
                                text: _channelData[index].max
                                color: _textColor
                                font.bold: true
                                font.family: "Microsoft YaHei"
                                font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.8
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                padding: 0
                                leftPadding: 0
                                rightPadding: 0
                                background: Rectangle {
                                    color: _inputBgColor
                                    border.color: _borderColor
                                    border.width: 1
                                }
                                validator: IntValidator { bottom: 500; top: 2500 }
                                onTextChanged: {
                                    var val = parseInt(text)
                                    if (!isNaN(val)) _channelData[index].max = val
                                }
                            }

                            // 反向设置复选框
                            Rectangle {
                                id: reverseCheck
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
                                color: "transparent"

                                // 正方块复选框
                                Rectangle {
                                    id: checkBox
                                    anchors.centerIn: parent
                                    width: ScreenTools.defaultFontPixelHeight * 1.5
                                    height: ScreenTools.defaultFontPixelHeight * 1.5
                                    color: _inputBgColor
                                    border.color: _borderColor
                                    border.width: 1

                                    // 打勾标记
                                    QGCLabel {
                                        id: checkMark
                                        anchors.centerIn: parent
                                        text: "✓"
                                        color: "#FFFFFF"
                                        font.bold: true
                                        font.pixelSize: ScreenTools.defaultFontPixelSize * 1.25
                                        visible: false
                                    }


                                    MouseArea {
                                        id: reverseMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            _channelData[index].reverse = !_channelData[index].reverse
                                            // 手动更新 UI 状态（property var 数组深层属性变化不会自动触发 UI 更新）
                                            checkBox.color = _channelData[index].reverse ? _btnBgColor : _inputBgColor
                                            checkMark.visible = _channelData[index].reverse
                                        }
                                    }
                                }
                            }

                            // 发送按钮
                            Rectangle {
                                id: sendBtn
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7
                                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
                                color: sendMouse.containsMouse ? _btnHoverColor : _btnBgColor

                                QGCLabel {
                                    anchors.centerIn: parent
                                    text: "发送"
                                    color: "#FFFFFF"
                                    font.bold: true
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.7
                                }


                                MouseArea {
                                    id: sendMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        console.log("发送通道" + (index + 1) + "配置: min=" + _channelData[index].min +
                                                    ", mid=" + _channelData[index].mid + ", max=" + _channelData[index].max +
                                                    ", func=" + _channelData[index].func)
                                    }
                                }
                            }

                            // 读取按钮
                            Rectangle {
                                id: readBtn
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7
                                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
                                color: readMouse.containsMouse ? _cancelHoverColor : _cancelBgColor
                                border.color: _borderColor
                                border.width: 1

                                QGCLabel {
                                    anchors.centerIn: parent
                                    text: "读取"
                                    color: _textColor
                                    font.bold: true
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.7
                                }

                                MouseArea {
                                    id: readMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        console.log("读取通道" + (index + 1) + "配置")
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
