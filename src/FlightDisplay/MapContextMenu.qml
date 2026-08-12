import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.ScreenTools 1.0

/// @brief 地图右键菜单弹窗 - 纯按钮列表风格
/// 在鼠标右键位置弹出，包含各类操作按钮
Popup {
    id: _root

    width: ScreenTools.defaultFontPixelWidth * 14
    modal: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    // 按钮点击信号
    signal locateVehicleClicked     // 定位飞机按钮点击信号
    signal clearTrajectoryClicked   // 清除轨迹按钮点击信号
    signal measureToolClicked       // 测量工具按钮点击信号
    signal exitClicked              // 退出按钮点击信号


    background: Rectangle {
        color: Qt.rgba(0.15, 0.15, 0.15, 0.9)
        radius: 4
        border.color: Qt.rgba(1, 1, 1, 0.15)
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        // ---- 定位飞机 ----
        Rectangle {
            id: locateBtn
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.6
            color: locateMouse.containsMouse ? "#4A4A4A" : "transparent"

            QGCLabel {
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                anchors.verticalCenter: parent.verticalCenter
                text: "定位飞机"
                color: "#FFFFFF"
                font.family: "Microsoft YaHei"
                font.bold: true
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            MouseArea {
                id: locateMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    _root.close()
                    _root.locateVehicleClicked()
                }
            }
        }

        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(1, 1, 1, 0.15)
        }

        // ---- 清除轨迹 ----
        Rectangle {
            id: clearTrajectoryBtn
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.6
            color: clearTrajectoryMouse.containsMouse ? "#4A4A4A" : "transparent"

            QGCLabel {
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                anchors.verticalCenter: parent.verticalCenter
                text: "清除轨迹"
                color: "#FFFFFF"
                font.family: "Microsoft YaHei"
                font.bold: true
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            MouseArea {
                id: clearTrajectoryMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    _root.close()
                    _root.clearTrajectoryClicked()
                }
            }
        }

        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(1, 1, 1, 0.15)
        }

        // ---- 测量尺 ----
        Rectangle {
            id: measureBtn
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.6
            color: measureMouse.containsMouse ? "#4A4A4A" : "transparent"

            QGCLabel {
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                anchors.verticalCenter: parent.verticalCenter
                text: "测量尺"
                color: "#FFFFFF"
                font.family: "Microsoft YaHei"
                font.bold: true
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            MouseArea {
                id: measureMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    _root.close()
                    _root.measureToolClicked()
                }
            }
        }

        // ---- 退出 ----

        Rectangle {
            id: exitBtn
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.6
            color: exitMouse.containsMouse ? "#5A2A2A" : "transparent"

            QGCLabel {
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                anchors.verticalCenter: parent.verticalCenter
                text: "退出"
                color: "#FF8A80"
                font.family: "Microsoft YaHei"
                font.bold: true
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            MouseArea {
                id: exitMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    _root.close()
                    _root.exitClicked()
                }
            }
        }
    }
}


