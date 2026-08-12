import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

Popup {
    id: themeSettingsDialog

    width: ScreenTools.defaultFontPixelWidth * 40
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    property var rootItem: null

    // 当前选中的主题（Light = 白天模式，Dark = 夜间模式）
    property int selectedTheme: QGroundControl.globalPalette ? QGroundControl.globalPalette.globalTheme : QGCPalette.Light

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
                text: "主题设置"
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
                    onClicked: themeSettingsDialog.close()
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
                    themeSettingsDialog.x += mouse.x - _startX
                    themeSettingsDialog.y += mouse.y - _startY
                }
            }
        }

        // ---- 内容区 ----
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.8
            color: "transparent"
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.5
            Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.5
            spacing: ScreenTools.defaultFontPixelHeight * 0.6

            // 白天模式
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.6
                radius: 4
                color: lightRowMouse.containsMouse ? Qt.rgba(0, 0, 0, 0.05) : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.8
                    anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 0.8
                    spacing: ScreenTools.defaultFontPixelWidth * 0.8

                    QGCLabel {
                        text: "白天模式"
                        font.family: "Microsoft YaHei"
                        font.bold: true
                        color: QGroundControl.globalPalette ? QGroundControl.globalPalette.text : "black"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    QGCCheckBox {
                        id: lightCheck
                        checked: themeSettingsDialog.selectedTheme === QGCPalette.Light
                        onClicked: {
                            themeSettingsDialog.selectedTheme = QGCPalette.Light
                        }
                    }
                }

                MouseArea {
                    id: lightRowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        themeSettingsDialog.selectedTheme = QGCPalette.Light
                    }
                }
            }

            // 夜间模式
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.6
                radius: 4
                color: darkRowMouse.containsMouse ? Qt.rgba(0, 0, 0, 0.05) : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.8
                    anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 0.8
                    spacing: ScreenTools.defaultFontPixelWidth * 0.8

                    QGCLabel {
                        text: "夜间模式"
                        font.family: "Microsoft YaHei"
                        font.bold: true
                        color: QGroundControl.globalPalette ? QGroundControl.globalPalette.text : "black"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    QGCCheckBox {
                        id: darkCheck
                        checked: themeSettingsDialog.selectedTheme === QGCPalette.Dark
                        onClicked: {
                            themeSettingsDialog.selectedTheme = QGCPalette.Dark
                        }
                    }
                }

                MouseArea {
                    id: darkRowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        themeSettingsDialog.selectedTheme = QGCPalette.Dark
                    }
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
                text: "确认"
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
                onClicked: {
                    // 应用选中的主题
                    if (QGroundControl.globalPalette) {
                        QGroundControl.globalPalette.globalTheme = themeSettingsDialog.selectedTheme
                    }
                    themeSettingsDialog.close()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.6
            color: "transparent"
        }
    }
}
