import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

import QGroundControl 1.0
import QGroundControl.Palette 1.0
import QGroundControl.Controls 1.0
import QGroundControl.ScreenTools 1.0

/// @brief 仪表盘下方遥测信息容器
/// 存放不同类别的遥测信息，每种遥测信息对应一个黑色透明框
/// 根据"重要信息配置"的勾选，动态显示对应的黑色透明框
Flickable {
    id: _root
    width: parent.width
    height: ScreenTools.defaultFontPixelHeight *37
    contentHeight: _contentColumn.height
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    QGCPalette { id: qgcPal }

    // ============ 主题模式（dayMode / nightMode）============
    // 通过 qgcPal.globalTheme 判断：Light = 白天模式，Dark = 夜间模式
    property bool dayMode: qgcPal.globalTheme === QGCPalette.Light

    // 信息框背景色
    property color panelBackgroundColor: dayMode ? Qt.rgba(0.95, 0.95, 0.97, 0.95) : Qt.rgba(0.05, 0.05, 0.08, 0.92)
    // 信息框边框色
    property color panelBorderColor:     dayMode ? Qt.rgba(0.2, 0.3, 0.5, 0.4)      : Qt.rgba(0.2, 0.3, 0.5, 0.4)
    // 标题字体颜色
    property color titleColor:           dayMode ? "#1565C0"                        : "#4FC3F7"

    // 配置项选中状态（由 ConfigMenu 控制）
    property bool engineChecked:    true
    property bool gpsChecked:       true
    property bool attitudeChecked:  true
    property bool voltageChecked:   true
    property bool fuelChecked:      true
    property bool airspeedChecked:  true
    property bool modeChecked:      true

    // 当前活动飞机（由 FlyViewWidgetLayer 传入，用于读取飞控姿态数据）
    property var activeVehicle:     null

    // 重点信息栏配置弹窗共享实例（由 FlyViewWidgetLayer 传入，用于打开配置弹窗）
    property var configMenuInstance: null

    // 右键菜单弹窗 - 仅含"配置"按钮
    Popup {
        id: _contextMenu
        width: ScreenTools.defaultFontPixelWidth * 14
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0

        background: Rectangle {
            color: Qt.rgba(0.15, 0.15, 0.15, 0.9)
            radius: 4
            border.color: Qt.rgba(1, 1, 1, 0.15)
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 0

            // ---- 配置 ----
            Rectangle {
                id: configBtn
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.6
                color: configMouse.containsMouse ? "#4A4A4A" : "transparent"

                QGCLabel {
                    anchors.left: parent.left
                    anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                    anchors.verticalCenter: parent.verticalCenter
                    text: "配置"
                    color: "#FFFFFF"
                    font.family: "Microsoft YaHei"
                    font.bold: true
                    font.pixelSize: ScreenTools.defaultFontPixelSize
                }

                MouseArea {
                    id: configMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        _contextMenu.close()
                        if (_root.configMenuInstance) {
                            _root.configMenuInstance.open()
                        }
                    }
                }
            }
        }
    }

    // 右键触发区域：鼠标在遥测信息容器内右键时弹出配置菜单
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        z: 100

        onClicked: {
            if (mouse.button === Qt.RightButton) {
                var globalPos = _root.mapToGlobal(mouse.x, mouse.y)
                var overlayPos = _contextMenu.parent.mapFromGlobal(globalPos.x, globalPos.y)
                _contextMenu.x = overlayPos.x
                _contextMenu.y = overlayPos.y
                _contextMenu.open()
            }
        }
    }

    Column {




        id: _contentColumn
        width: parent.width
        spacing: 0

    // ===== 发动机黑色透明框 =====
    Rectangle {
        id: engineBox
        width: parent.width
        height: ScreenTools.defaultFontPixelHeight * 6.5
        color: _root.panelBackgroundColor
        radius: 0
        border.color: _root.panelBorderColor
        border.width: 0
        visible: _root.engineChecked



        Column {
            anchors.fill: parent
            anchors.margins: ScreenTools.defaultFontPixelWidth * 0.8
            spacing: ScreenTools.defaultFontPixelHeight * 0.2

            // 标题
            QGCLabel {
                text: "发动机"
                color: _root.titleColor
                font.family: "Microsoft YaHei"
                font.bold: true
                font.pixelSize: ScreenTools.defaultFontPixelSize        //默认字体大小
            }

            // 分隔线
            Rectangle {
                width: parent.width
                height: 1
                color: _root.panelBorderColor
                //color: Qt.rgba(1, 1, 1, 0.15)
            }

            // 数据项网格
            GridLayout {            
                width: parent.width
                columns: 2
                rowSpacing: ScreenTools.defaultFontPixelHeight * 0.2
                columnSpacing: ScreenTools.defaultFontPixelWidth * 0.5

                // 转速1
                DataItem {
                    Layout.fillWidth: true
                    label: "转速1"
                    value: " -- "
                    unit: " RPM"
                }
                // 油门1
                DataItem {
                    Layout.fillWidth: true
                    label: "油门1"
                    value: activeVehicle ? activeVehicle.throttlePct.value : "--"
                    unit: " %"
                }
                // 排气温度
                DataItem {
                    Layout.fillWidth: true
                    label: "排气温度"
                    value: " -- "
                    unit: " °C"
                }
                // 运行时间
                DataItem {
                    Layout.fillWidth: true
                    label: "运行时间"
                    value: " -- "
                    unit: " h"
                }

            }
        }
    }

    // ===== GPS定位黑色透明框 =====
    Rectangle { 
        id: gpsBox
        width: parent.width
        height: ScreenTools.defaultFontPixelHeight * 10.5
        color: _root.panelBackgroundColor
        radius: 0
        border.color: _root.panelBorderColor
        border.width: 0
        visible: _root.gpsChecked



        Column {
            anchors.fill: parent
            anchors.margins: ScreenTools.defaultFontPixelWidth * 0.8
            spacing: ScreenTools.defaultFontPixelHeight * 0.2

            // 标题
            QGCLabel {
                text: "GPS定位"
                color: _root.titleColor
                font.family: "Microsoft YaHei"
                font.bold: true
                font.pixelSize: ScreenTools.defaultFontPixelSize *1.2
            }

            // 分隔线
            Rectangle {
                width: parent.width
                height: 1
                color: _root.panelBorderColor
                //color: Qt.rgba(1, 1, 1, 0.15)
            }

            // 数据项网格
            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: ScreenTools.defaultFontPixelHeight * 0.2
                columnSpacing: ScreenTools.defaultFontPixelWidth * 0.5

                // 经度
                DataItem {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    label: "经度"
                    value: activeVehicle ? activeVehicle.gps.lon.value.toFixed(7) : "--"
                    unit: "°"
                }
                // 纬度
                DataItem {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    label: "纬度"
                    value: activeVehicle ? activeVehicle.gps.lat.value.toFixed(7) : "--"
                    unit: "°"
                }
                // 高度
                DataItem {
                    Layout.fillWidth: true
                    label: "高度"
                    value: activeVehicle ? activeVehicle.altitudeRelative.value.toFixed(1) : "--"
                    unit: " m"
                }
                // 定位模式
                DataItem {
                    Layout.fillWidth: true
                    label: "定位模式"
                    value: activeVehicle ? activeVehicle.gps.lock.enumStringValue : "--"
                    unit: ""
                }
                // GPS星数
                DataItem {
                    Layout.fillWidth: true
                    label: "GPS星数"
                    value: activeVehicle ? activeVehicle.gps.count.value : "--"
                    unit: ""
                }
                // 地速
                DataItem {
                    Layout.fillWidth: true
                    label: "地速"
                    value: activeVehicle ? activeVehicle.groundSpeed.value.toFixed(1) : "--"
                    unit: " m/s"
                }

            }
        }
    }

    // ===== 飞机姿态黑色透明框 =====
    Rectangle {
        id: attitudeBox
        width: parent.width
        height: ScreenTools.defaultFontPixelHeight * 6.0
        color: _root.panelBackgroundColor
        radius: 0
        border.color: _root.panelBorderColor
        border.width: 0
        visible: _root.attitudeChecked



        Column {
            anchors.fill: parent
            anchors.margins: ScreenTools.defaultFontPixelWidth * 0.8
            spacing: ScreenTools.defaultFontPixelHeight * 0.2

            // 标题
            QGCLabel {
                text: "飞机姿态"
                color: _root.titleColor
                font.family: "Microsoft YaHei"
                font.bold: true
                font.pixelSize: ScreenTools.defaultFontPixelSize *1.2
            }

            // 分隔线
            Rectangle {
                width: parent.width
                height: 1
                color: _root.panelBorderColor
                //color: Qt.rgba(1, 1, 1, 0.15)
            }

            // 数据项网格
            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: ScreenTools.defaultFontPixelHeight * 0.2
                columnSpacing: ScreenTools.defaultFontPixelWidth * 0.5

                // 俯仰角
                DataItem {
                    Layout.fillWidth: true
                    label: "俯仰角"
                    value: activeVehicle ? activeVehicle.pitch.value.toFixed(1) : "--"
                    unit: "°"
                }
                // 滚转角
                DataItem {
                    Layout.fillWidth: true
                    label: "滚转角"
                    value: activeVehicle ? activeVehicle.roll.value.toFixed(1) : "--"
                    unit: "°"
                }
                // 航向角
                DataItem {
                    Layout.fillWidth: true
                    label: "航向角"
                    value: activeVehicle ? activeVehicle.heading.value.toFixed(1) : "--"
                    unit: "°"
                }
            }
        }
    }

    // ===== 电压监控黑色透明框 =====
    Rectangle {
        id: voltageBox
        width: parent.width
        height: ScreenTools.defaultFontPixelHeight * 4.5
        color: _root.panelBackgroundColor
        radius: 0
        border.color: _root.panelBorderColor
        border.width: 0
        visible: _root.voltageChecked



        Column {
            anchors.fill: parent
            anchors.margins: ScreenTools.defaultFontPixelWidth * 0.8
            spacing: ScreenTools.defaultFontPixelHeight * 0.2

            // 标题
            QGCLabel {
                text: "电压监控"
                color: _root.titleColor
                font.family: "Microsoft YaHei"
                font.bold: true
                font.pixelSize: ScreenTools.defaultFontPixelSize *1.2
            }

            // 分隔线
            Rectangle {
                width: parent.width
                height: 1
                color: _root.panelBorderColor
                //color: Qt.rgba(1, 1, 1, 0.15)
            }

            // 数据项网格
            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: ScreenTools.defaultFontPixelHeight * 0.2
                columnSpacing: ScreenTools.defaultFontPixelWidth * 0.5

                // 电压1
                DataItem {
                    Layout.fillWidth: true
                    label: "电压1"
                    value: "--"
                    unit: " V"
                }
                // 电压2
                DataItem {
                    Layout.fillWidth: true
                    label: "电压2"
                    value: "--"
                    unit: " V"
                }
            }
        }
    }

    // ===== 油量黑色透明框 =====
    Rectangle {
        id: fuelBox
        width: parent.width
        height: ScreenTools.defaultFontPixelHeight * 4.5
        color: _root.panelBackgroundColor
        radius: 0
        border.color: _root.panelBorderColor
        border.width: 0
        visible: _root.fuelChecked



        Column {
            anchors.fill: parent
            anchors.margins: ScreenTools.defaultFontPixelWidth * 0.8
            spacing: ScreenTools.defaultFontPixelHeight * 0.2

            // 标题
            QGCLabel {
                text: "油量"
                color: _root.titleColor
                font.family: "Microsoft YaHei"
                font.bold: true
                font.pixelSize: ScreenTools.defaultFontPixelSize *1.2
            }

            // 分隔线
            Rectangle {
                width: parent.width
                height: 1
                color: _root.panelBorderColor
                //color: Qt.rgba(1, 1, 1, 0.15)
            }

            // 数据项网格
            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: ScreenTools.defaultFontPixelHeight * 0.2
                columnSpacing: ScreenTools.defaultFontPixelWidth * 0.5

                // 油量1
                DataItem {
                    Layout.fillWidth: true
                    label: "油量1"
                    value: "--"
                    unit: " %"
                }
                // 油量2
                DataItem {
                    Layout.fillWidth: true
                    label: "油量2"
                    value: "--"
                    unit: " %"
                }
            }
        }
    }

    // ===== 空速黑色透明框 =====
    Rectangle {
        id: airspeedBox
        width: parent.width
        height: ScreenTools.defaultFontPixelHeight * 4.5
        color: _root.panelBackgroundColor
        radius: 0
        border.color: _root.panelBorderColor
        border.width: 0
        visible: _root.airspeedChecked



        Column {
            anchors.fill: parent
            anchors.margins: ScreenTools.defaultFontPixelWidth * 0.8
            spacing: ScreenTools.defaultFontPixelHeight * 0.2

            // 标题
            QGCLabel {
                text: "空速"
                color: _root.titleColor
                font.family: "Microsoft YaHei"
                font.bold: true
                font.pixelSize: ScreenTools.defaultFontPixelSize *1.2
            }

            // 分隔线
            Rectangle {
                width: parent.width
                height: 1
                color: _root.panelBorderColor
                //color: Qt.rgba(1, 1, 1, 0.15)
            }

            // 数据项网格
            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: ScreenTools.defaultFontPixelHeight * 0.2
                columnSpacing: ScreenTools.defaultFontPixelWidth * 0.5

                // 空速1
                DataItem {
                    Layout.fillWidth: true
                    label: "空速1"
                    value: activeVehicle ? activeVehicle.airSpeed.value.toFixed(1) : "--"
                    unit: " m/s"
                }
                // 空速2
                DataItem {
                    Layout.fillWidth: true
                    label: "空速2"
                    value: "--"
                    unit: " m/s"
                }

            }
        }
    }

    // ===== 控制模式黑色透明框 =====
    Rectangle {
        id: modeBox
        width: parent.width
        height: ScreenTools.defaultFontPixelHeight * 6.5
        color: _root.panelBackgroundColor
        radius: 0
        border.color: _root.panelBorderColor
        border.width: 0
        visible: _root.modeChecked



        Column {
            anchors.fill: parent
            anchors.margins: ScreenTools.defaultFontPixelWidth * 0.8
            spacing: ScreenTools.defaultFontPixelHeight * 0.2

            // 标题
            QGCLabel {
                text: "控制模式"
                color: _root.titleColor
                font.family: "Microsoft YaHei"
                font.bold: true
                font.pixelSize: ScreenTools.defaultFontPixelSize *1.2
            }

            // 分隔线
            Rectangle {
                width: parent.width
                height: 1
                color: _root.panelBorderColor
                //color: Qt.rgba(1, 1, 1, 0.15)
            }

            // 数据项网格
            GridLayout {
                width: parent.width
                columns: 1
                rowSpacing: ScreenTools.defaultFontPixelHeight * 0.2
                columnSpacing: ScreenTools.defaultFontPixelWidth * 0.5

                // 控制模式
                DataItem {
                    Layout.fillWidth: true
                    label: "控制模式"
                    value: activeVehicle ? activeVehicle.flightMode : "--"
                    unit: ""
                }
                // 固件类型
                DataItem {
                    Layout.fillWidth: true
                    label: "固件类型"
                    value: activeVehicle ? activeVehicle.firmwareTypeString : "--"
                    unit: ""
                }

            }


        }
    }
    }
}
