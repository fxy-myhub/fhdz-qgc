import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.ScreenTools 1.0

Popup {
    id: engineConfigDialog

    width: ScreenTools.defaultFontPixelWidth * 40
    modal: false
    closePolicy: Popup.CloseOnEscape
    padding: 0

    property var rootItem: null

    background: Rectangle {
        color: QGroundControl.globalPalette ? QGroundControl.globalPalette.window : "#FFFFFF"
        radius: 6
        border.color: Qt.rgba(0, 0, 0, 0.2)
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        // ---- 标题栏（可拖拽） ----
        Rectangle {
            id: titleBar
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
            color: "#1976D2"
            radius: 6

            // 只保留顶部圆角
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height - 6
                color: "#1976D2"
            }

            QGCLabel {
                anchors.centerIn: parent
                text: "发动机配置"
                color: "white"
                font.bold: true
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize * 1.1
            }

            // 关闭按钮
            Rectangle {
                id: closeBtn
                anchors.right: parent.right
                anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 0.8
                anchors.verticalCenter: parent.verticalCenter
                width: ScreenTools.defaultFontPixelHeight * 1.1
                height: ScreenTools.defaultFontPixelHeight * 1.1
                radius: width / 2
                color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : "transparent"

                QGCLabel {
                    anchors.centerIn: parent
                    text: "✕"
                    color: "white"
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: engineConfigDialog.close()
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
                    engineConfigDialog.x += mouse.x - _startX
                    engineConfigDialog.y += mouse.y - _startY
                }
            }
        }

        // ---- 内容区 ----
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.6
            color: "transparent"
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.5
            Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.5
            columns: 2
            columnSpacing: ScreenTools.defaultFontPixelWidth * 1.0
            rowSpacing: ScreenTools.defaultFontPixelHeight * 0.6

            // 第一行：品牌 / 型号
            QGCLabel {
                text: "品牌"
                font.family: "Microsoft YaHei"
                font.bold: true
            }
            QGCComboBox {
                id: brandCombo
                Layout.fillWidth: true
                sizeToContents: true
                model: ["DJI", "Yamaha", "Honda", "Rotax", "其他"]
                popup.parent: Overlay.overlay
                popup.onOpened: {
                    var globalPos = brandCombo.mapToGlobal(0, brandCombo.height)
                    var overlayPos = Overlay.overlay.mapFromGlobal(globalPos.x, globalPos.y)
                    popup.x = overlayPos.x
                    popup.y = overlayPos.y
                    popup.z = engineConfigDialog.z + 10
                }
            }

            QGCLabel {
                text: "型号"
                font.family: "Microsoft YaHei"
                font.bold: true
            }
            QGCComboBox {
                id: modelCombo
                Layout.fillWidth: true
                sizeToContents: true
                model: ["Model-A", "Model-B", "Model-C", "Model-D"]
                popup.parent: Overlay.overlay
                popup.onOpened: {
                    var globalPos = modelCombo.mapToGlobal(0, modelCombo.height)
                    var overlayPos = Overlay.overlay.mapFromGlobal(globalPos.x, globalPos.y)
                    popup.x = overlayPos.x
                    popup.y = overlayPos.y
                    popup.z = engineConfigDialog.z + 10
                }
            }

            // 第二行：串口 / 波特率
            QGCLabel {
                text: "串口"
                font.family: "Microsoft YaHei"
                font.bold: true
            }
            QGCComboBox {
                id: serialCombo
                Layout.fillWidth: true
                sizeToContents: true
                model: ["COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "/dev/ttyS0", "/dev/ttyUSB0"]
                popup.parent: Overlay.overlay
                popup.onOpened: {
                    var globalPos = serialCombo.mapToGlobal(0, serialCombo.height)
                    var overlayPos = Overlay.overlay.mapFromGlobal(globalPos.x, globalPos.y)
                    popup.x = overlayPos.x
                    popup.y = overlayPos.y
                    popup.z = engineConfigDialog.z + 10
                }
            }

            QGCLabel {
                text: "波特率"
                font.family: "Microsoft YaHei"
                font.bold: true
            }
            QGCComboBox {
                id: baudCombo
                Layout.fillWidth: true
                sizeToContents: true
                model: ["9600", "19200", "38400", "57600", "115200", "230400"]
                popup.parent: Overlay.overlay
                popup.onOpened: {
                    var globalPos = baudCombo.mapToGlobal(0, baudCombo.height)
                    var overlayPos = Overlay.overlay.mapFromGlobal(globalPos.x, globalPos.y)
                    popup.x = overlayPos.x
                    popup.y = overlayPos.y
                    popup.z = engineConfigDialog.z + 10
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.8
            color: "transparent"
        }

        // 确认按钮
        Rectangle {
            id: confirmBtn
            Layout.fillWidth: true
            Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.5
            Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.5
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: confirmMouse.containsMouse ? "#1565C0" : "#1976D2"

            QGCLabel {
                anchors.centerIn: parent
                text: "确认配置"
                color: "white"
                font.bold: true
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            MouseArea {
                id: confirmMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: engineConfigDialog.close()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.6
            color: "transparent"
        }
    }
}
