/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGC is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.12
import QtQuick.Controls         2.4
import QtQuick.Layouts          1.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0
import QGroundControl.Vehicle       1.0

Rectangle {
    id: _root

    QGCPalette { id: qgcPal }

    property var activeVehicle: null
    property bool panelVisible: false
    
    signal closed()
    
    // 根元素尺寸 - 高度实时与侧拉框内 QGCLabel 数量及高度保持同步
    width: ScreenTools.defaultFontPixelWidth * 2
    height: parameterPanel.height
    color: "transparent"
    border.width: 0

    
    // 侧拉按钮 - 白色竖条
    Rectangle {
        id: drawerButton
        anchors.fill: parent
        color: qgcPal.window
        radius: 5

        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                _root.panelVisible = !_root.panelVisible
            }
        }
        
    }
    
    // 参数显示面板 - 无滚动，高度实时与内容 QGCLabel 数量及高度保持同步
    Rectangle {
        id: parameterPanel
        anchors.left: drawerButton.right
        anchors.top: drawerButton.top
        width: ScreenTools.defaultFontPixelWidth * 15
        // 高度由内容列 implicitHeight 决定（含上下边距），随 QGCLabel 数量/高度实时变化
        height: contentColumn.implicitHeight + ScreenTools.defaultFontPixelWidth * 2
        color: qgcPal.window
        border.color: qgcPal.border
        border.width: 1
        visible: _root.panelVisible

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: ScreenTools.defaultFontPixelWidth

            // 飞行阶段
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5

                QGCLabel {
                    text: "飞行阶段"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }

                Item {
                    Layout.fillWidth: true
                }

                QGCLabel {
                    text: activeVehicle ? activeVehicle.flightMode : "--"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }
            }

            // 分割线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: qgcPal.text
            }

            // 主电压
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5

                QGCLabel {
                    text: "主电压"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }

                Item {
                    Layout.fillWidth: true
                }

                QGCLabel {
                    text: activeVehicle && activeVehicle.battery ? activeVehicle.battery[0].voltage.valueString : "--"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }
            }

            // 电压二
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5

                QGCLabel {
                    text: "电压二"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }

                Item {
                    Layout.fillWidth: true
                }

                QGCLabel {
                    text: activeVehicle && activeVehicle.battery && activeVehicle.battery[1] ? activeVehicle.battery[1].voltage.valueString : "--"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }
            }

            // 油门
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5

                QGCLabel {
                    text: "油门"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }

                Item {
                    Layout.fillWidth: true
                }

                QGCLabel {
                    text: activeVehicle ? (activeVehicle.throttlePercent !== undefined ? activeVehicle.throttlePercent.toFixed(0) + "%" : "--") : "--"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }
            }

            // 空速
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5

                QGCLabel {
                    text: "空速"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }

                Item {
                    Layout.fillWidth: true
                }

                QGCLabel {
                    text: activeVehicle ? activeVehicle.airspeed.valueString : "--"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }
            }

            // 地速
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5

                QGCLabel {
                    text: "地速"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }

                Item {
                    Layout.fillWidth: true
                }

                QGCLabel {
                    text: activeVehicle ? activeVehicle.groundspeed.valueString : "--"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }
            }

            // 高度
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5

                QGCLabel {
                    text: "高度"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }

                Item {
                    Layout.fillWidth: true
                }

                QGCLabel {
                    text: activeVehicle ? activeVehicle.altitudeRelative.valueString : "--"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }
            }

            // 对地高度
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5

                QGCLabel {
                    text: "对地高度"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }

                Item {
                    Layout.fillWidth: true
                }

                QGCLabel {
                    text: activeVehicle ? activeVehicle.altitudeAboveTerrain.valueString : "--"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }
            }

            // 原点距离
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5

                QGCLabel {
                    text: "原点距离"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }

                Item {
                    Layout.fillWidth: true
                }

                QGCLabel {
                    text: "--"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }
            }
        }
    }
}

