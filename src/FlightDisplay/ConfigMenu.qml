import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.ScreenTools 1.0

/// @brief 重点信息栏配置弹窗
/// 顶部标题 + 右上角关闭按钮 + 多选复选框列表
Popup {
    id: _root

    width: ScreenTools.defaultFontPixelWidth * 16
    height: ScreenTools.defaultFontPixelHeight * 16
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    // 配置项的选中状态（供外部读取）
    property bool engineChecked:    true
    property bool gpsChecked:       true
    property bool attitudeChecked:  true
    property bool voltageChecked:   true
    property bool fuelChecked:      true
    property bool airspeedChecked:  true
    property bool modeChecked:      true

    // 关闭信号
    signal closed

    background: Rectangle {
        color: Qt.rgba(0.15, 0.15, 0.15, 0.95)
        radius: 6
        border.color: Qt.rgba(1, 1, 1, 0.2)
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        // ===== 顶部标题栏 =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
            color: Qt.rgba(0.2, 0.2, 0.2, 1)

            QGCLabel {
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                anchors.verticalCenter: parent.verticalCenter
                text: "重点信息栏配置"
                color: "#FFFFFF"
                font.family: "Microsoft YaHei"
                font.bold: true
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            // 关闭 X 按钮
            Rectangle {
                id: closeBtn
                anchors.right: parent.right
                anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 0.5
                anchors.verticalCenter: parent.verticalCenter
                width: ScreenTools.defaultFontPixelHeight * 1.2
                height: ScreenTools.defaultFontPixelHeight * 1.2
                radius: 3
                color: closeMouse.containsMouse ? "#4A4A4A" : "transparent"

                QGCLabel {
                    anchors.centerIn: parent
                    text: "✕"
                    color: "#FFFFFF"
                    font.pixelSize: ScreenTools.defaultFontPixelSize
                    font.bold: true
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        _root.close()
                        _root.closed()
                    }
                }
            }
        }

        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(1, 1, 1, 0.15)
        }

        // ===== 多选复选框列表 =====
        // 发动机
        Rectangle {
            id: engineRow
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
            color: engineMouse.containsMouse ? "#2A2A2A" : "transparent"

            // 方形 checkbox
            Rectangle {
                id: engineCheck
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                anchors.verticalCenter: parent.verticalCenter
                width: ScreenTools.defaultFontPixelHeight * 0.9
                height: ScreenTools.defaultFontPixelHeight * 0.9
                radius: 2
                border.color: _root.engineChecked ? "#2196F3" : Qt.rgba(1, 1, 1, 0.4)
                border.width: 2
                color: _root.engineChecked ? "#2196F3" : "transparent"

                // 选中勾号
                QGCLabel {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "#FFFFFF"
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                    font.bold: true
                    visible: _root.engineChecked
                }
            }

            QGCLabel {
                anchors.left: engineCheck.right
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.8
                anchors.verticalCenter: parent.verticalCenter
                text: "发动机"
                color: _root.engineChecked ? "#FFFFFF" : "#B0B0B0"
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            MouseArea {
                id: engineMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: _root.engineChecked = !_root.engineChecked
            }
        }

        // GPS定位
        Rectangle {
            id: gpsRow
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
            color: gpsMouse.containsMouse ? "#2A2A2A" : "transparent"

            Rectangle {
                id: gpsCheck
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                anchors.verticalCenter: parent.verticalCenter
                width: ScreenTools.defaultFontPixelHeight * 0.9
                height: ScreenTools.defaultFontPixelHeight * 0.9
                radius: 2
                border.color: _root.gpsChecked ? "#2196F3" : Qt.rgba(1, 1, 1, 0.4)
                border.width: 2
                color: _root.gpsChecked ? "#2196F3" : "transparent"

                QGCLabel {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "#FFFFFF"
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                    font.bold: true
                    visible: _root.gpsChecked
                }
            }

            QGCLabel {
                anchors.left: gpsCheck.right
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.8
                anchors.verticalCenter: parent.verticalCenter
                text: "GPS定位"
                color: _root.gpsChecked ? "#FFFFFF" : "#B0B0B0"
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            MouseArea {
                id: gpsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: _root.gpsChecked = !_root.gpsChecked
            }
        }

        // 飞机姿态
        Rectangle {
            id: attitudeRow
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
            color: attitudeMouse.containsMouse ? "#2A2A2A" : "transparent"

            Rectangle {
                id: attitudeCheck
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                anchors.verticalCenter: parent.verticalCenter
                width: ScreenTools.defaultFontPixelHeight * 0.9
                height: ScreenTools.defaultFontPixelHeight * 0.9
                radius: 2
                border.color: _root.attitudeChecked ? "#2196F3" : Qt.rgba(1, 1, 1, 0.4)
                border.width: 2
                color: _root.attitudeChecked ? "#2196F3" : "transparent"

                QGCLabel {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "#FFFFFF"
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                    font.bold: true
                    visible: _root.attitudeChecked
                }
            }

            QGCLabel {
                anchors.left: attitudeCheck.right
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.8
                anchors.verticalCenter: parent.verticalCenter
                text: "飞机姿态"
                color: _root.attitudeChecked ? "#FFFFFF" : "#B0B0B0"
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            MouseArea {
                id: attitudeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: _root.attitudeChecked = !_root.attitudeChecked
            }
        }

        // 电压监控
        Rectangle {
            id: voltageRow
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
            color: voltageMouse.containsMouse ? "#2A2A2A" : "transparent"

            Rectangle {
                id: voltageCheck
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                anchors.verticalCenter: parent.verticalCenter
                width: ScreenTools.defaultFontPixelHeight * 0.9
                height: ScreenTools.defaultFontPixelHeight * 0.9
                radius: 2
                border.color: _root.voltageChecked ? "#2196F3" : Qt.rgba(1, 1, 1, 0.4)
                border.width: 2
                color: _root.voltageChecked ? "#2196F3" : "transparent"

                QGCLabel {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "#FFFFFF"
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                    font.bold: true
                    visible: _root.voltageChecked
                }
            }

            QGCLabel {
                anchors.left: voltageCheck.right
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.8
                anchors.verticalCenter: parent.verticalCenter
                text: "电压监控"
                color: _root.voltageChecked ? "#FFFFFF" : "#B0B0B0"
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            MouseArea {
                id: voltageMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: _root.voltageChecked = !_root.voltageChecked
            }
        }

        // 油量
        Rectangle {
            id: fuelRow
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
            color: fuelMouse.containsMouse ? "#2A2A2A" : "transparent"

            Rectangle {
                id: fuelCheck
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                anchors.verticalCenter: parent.verticalCenter
                width: ScreenTools.defaultFontPixelHeight * 0.9
                height: ScreenTools.defaultFontPixelHeight * 0.9
                radius: 2
                border.color: _root.fuelChecked ? "#2196F3" : Qt.rgba(1, 1, 1, 0.4)
                border.width: 2
                color: _root.fuelChecked ? "#2196F3" : "transparent"

                QGCLabel {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "#FFFFFF"
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                    font.bold: true
                    visible: _root.fuelChecked
                }
            }

            QGCLabel {
                anchors.left: fuelCheck.right
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.8
                anchors.verticalCenter: parent.verticalCenter
                text: "油量"
                color: _root.fuelChecked ? "#FFFFFF" : "#B0B0B0"
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            MouseArea {
                id: fuelMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: _root.fuelChecked = !_root.fuelChecked
            }
        }

        // 空速
        Rectangle {
            id: airspeedRow
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
            color: airspeedMouse.containsMouse ? "#2A2A2A" : "transparent"

            Rectangle {
                id: airspeedCheck
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                anchors.verticalCenter: parent.verticalCenter
                width: ScreenTools.defaultFontPixelHeight * 0.9
                height: ScreenTools.defaultFontPixelHeight * 0.9
                radius: 2
                border.color: _root.airspeedChecked ? "#2196F3" : Qt.rgba(1, 1, 1, 0.4)
                border.width: 2
                color: _root.airspeedChecked ? "#2196F3" : "transparent"

                QGCLabel {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "#FFFFFF"
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                    font.bold: true
                    visible: _root.airspeedChecked
                }
            }

            QGCLabel {
                anchors.left: airspeedCheck.right
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.8
                anchors.verticalCenter: parent.verticalCenter
                text: "空速"
                color: _root.airspeedChecked ? "#FFFFFF" : "#B0B0B0"
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            MouseArea {
                id: airspeedMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: _root.airspeedChecked = !_root.airspeedChecked
            }
        }

        // 控制模式
        Rectangle {
            id: modeRow
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.8
            color: modeMouse.containsMouse ? "#2A2A2A" : "transparent"

            Rectangle {
                id: modeCheck
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                anchors.verticalCenter: parent.verticalCenter
                width: ScreenTools.defaultFontPixelHeight * 0.9
                height: ScreenTools.defaultFontPixelHeight * 0.9
                radius: 2
                border.color: _root.modeChecked ? "#2196F3" : Qt.rgba(1, 1, 1, 0.4)
                border.width: 2
                color: _root.modeChecked ? "#2196F3" : "transparent"

                QGCLabel {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "#FFFFFF"
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                    font.bold: true
                    visible: _root.modeChecked
                }
            }

            QGCLabel {
                anchors.left: modeCheck.right
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.8
                anchors.verticalCenter: parent.verticalCenter
                text: "控制模式"
                color: _root.modeChecked ? "#FFFFFF" : "#B0B0B0"
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            MouseArea {
                id: modeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: _root.modeChecked = !_root.modeChecked
            }
        }
    }
}
