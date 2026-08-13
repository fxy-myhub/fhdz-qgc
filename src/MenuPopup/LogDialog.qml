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


/// @brief 日志信息弹窗
/// 标题 + 日志列表
/// 数据来源：飞控发来的 STATUSTEXT 消息（通过 activeVehicle.textMessageReceived 信号）

Popup {
    id: logDialog
    width: ScreenTools.defaultFontPixelWidth * 130
    height: ScreenTools.defaultFontPixelHeight * 45
    modal: false
    closePolicy: Popup.CloseOnEscape
    padding: 0

    property var rootItem: null

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
    readonly property color _btnBgColor:        "#1976D2"                          // 主按钮背景（保持蓝色）
    readonly property color _btnHoverColor:     "#1565C0"                          // 主按钮悬停（保持蓝色）
    readonly property color _cancelBgColor:     dayMode ? "#E0E0E0" : "#3A3A3A"   // 次按钮背景
    readonly property color _cancelHoverColor:  dayMode ? "#D0D0D0" : "#4A4A4A"   // 次按钮悬停
    readonly property color _borderColor:       dayMode ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(1, 1, 1, 0.15)  // 分隔线/边框

    // 警告消息颜色（黄色）
    readonly property color _warningColor:      "#FFC107"
    // 错误消息颜色（红色）
    readonly property color _errorColor:        "#F44336"

    // 飞控 STATUSTEXT 消息列表模型
    ListModel {
        id: statusTextModel
    }

    // 根据严重级别返回信息类型文本（中文）
    function severityText(severity) {
        switch (severity) {
        case 0: return "紧急:"       // MAV_SEVERITY_EMERGENCY
        case 1: return "警报:"       // MAV_SEVERITY_ALERT
        case 2: return "严重:"       // MAV_SEVERITY_CRITICAL
        case 3: return "错误:"       // MAV_SEVERITY_ERROR
        case 4: return "警告:"       // MAV_SEVERITY_WARNING
        case 5: return "提示:"       // MAV_SEVERITY_NOTICE
        case 6: return "信息:"       // MAV_SEVERITY_INFO
        case 7: return "调试:"       // MAV_SEVERITY_DEBUG
        default: return ""
        }
    }


    // 监听当前活动车辆发来的 STATUSTEXT 消息
    Connections {
        target: QGroundControl.multiVehicleManager.activeVehicle
        onTextMessageReceived: {
            statusTextModel.append({
                "time":         new Date().toLocaleTimeString(Qt.locale(), "hh:mm:ss.zzz"),
                "severityText": severityText(severity),
                "message":      text,
                "severity":     severity
            })
            logListView.positionViewAtEnd()
        }
    }


    // 监听车辆切换，切换时清空消息列表
    Connections {
        target: QGroundControl.multiVehicleManager
        onActiveVehicleChanged: {
            statusTextModel.clear()
        }
    }

    // 打开弹窗时滚动到最新日志
    onOpened: {
        logListView.positionViewAtEnd()
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
                text: "日志信息"
                color: "#FFFFFF"
                font.bold: true
                font.family: "Microsoft YaHei"
                font.pointSize: ScreenTools.largeFontPointSize
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
                    font.pointSize: ScreenTools.largeFontPointSize
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: logDialog.close()
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
                    logDialog.x += mouse.x - _startX
                    logDialog.y += mouse.y - _startY
                }
            }
        }

        // ---- 日志列表 ----
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: _bgColor

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 日志列表（可滚动）
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ListView {
                        id: logListView
                        anchors.fill: parent
                        model: statusTextModel
                        clip: true

                        delegate: Rectangle {
                            width: logListView.width
                            height: Math.max(ScreenTools.defaultFontPixelHeight * 2.2, logText.height + ScreenTools.defaultFontPixelHeight * 0.8)
                            color: (index % 2 === 0) ? _rowEvenColor : _rowOddColor

                            // 根据消息严重级别确定文字颜色：
                            // 错误级别（EMERGENCY/ALERT/CRITICAL/ERROR）→ 红色
                            // 警告级别（WARNING/NOTICE）→ 黄色
                            // 正常级别（INFO/DEBUG）→ 默认颜色
                            readonly property color _msgColor: severity <= 3 ? _errorColor : (severity <= 5 ? _warningColor : _textColor)

                            // 三列布局：时间 | 信息类型 | 信息
                            RowLayout {
                                anchors.left: parent.left
                                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.0
                                anchors.right: parent.right
                                anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 1.0
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: ScreenTools.defaultFontPixelWidth * 0.5

                                // 第一列：时间
                                QGCLabel {
                                    id: timeText
                                    text: time
                                    color: _textColor
                                    font.family: "Microsoft YaHei"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 14
                                }

                                // 第二列：信息类型
                                QGCLabel {
                                    id: severityTextLabel
                                    text: severityText
                                    color: parent.parent._msgColor
                                    font.family: "Microsoft YaHei"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    font.bold: true
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                                }

                                // 第三列：信息
                                QGCLabel {
                                    id: logText
                                    text: message
                                    color: parent.parent._msgColor
                                    font.family: "Microsoft YaHei"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                }
                            }
                        }

                    }

                }

                // 分隔线
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: _borderColor
                }

                // ---- 底部按钮栏 ----
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.5
                    Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.0
                    Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.0
                    spacing: ScreenTools.defaultFontPixelWidth

                    // 显示最新
                    QGCButton {
                        text: "显示最新"
                        checkable: true
                        checked: true
                        onClicked: {
                            if (checked) {
                                logListView.positionViewAtEnd()
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // 关闭按钮
                    QGCButton {
                        text: "关闭"
                        onClicked: logDialog.close()
                    }
                }
            }
        }
    }
}
