import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

Rectangle {
    id: menuBarView
    width: parent.width
    height: parent.height
    color: qgcPal.window

    QGCPalette { id: qgcPal }

    // 主题感知颜色
    property color menuBarBackground:    qgcPal.window
    property color menuBtnBackground:    qgcPal.window
    property color menuBtnHover:         qgcPal.windowShadeLight
    property color menuBtnText:          qgcPal.text

     property var mainWindow: null

    Row {
        anchors.fill: parent
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.5
        spacing: ScreenTools.defaultFontPixelWidth * 0.2

        // ===== 文件菜单 =====
        QGCButton {
            id: fileMenuBtn
            text: "文件(F)"
            width: implicitWidth + ScreenTools.defaultFontPixelWidth * 0.5
            height: parent.height
            flat: true

            background: Rectangle {
                color: fileMenuBtn.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: fileMenuBtn.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Microsoft YaHei"
                visible: true
                opacity: 1
            }

            onClicked: {
                if (fileMenu.visible) {
                    fileMenu.close()
                } else {
                    var pos = fileMenuBtn.mapToItem(mainWindow.contentItem, 0, 0)
                    fileMenu.x = pos.x
                    fileMenu.y = pos.y + fileMenuBtn.height + 2
                    fileMenu.open()
                }
            }
        }
        // ===== 初始配置菜单 =====
        QGCButton {
            id: initConfigMenuBtn
            text: "初始配置(I)"
            width: implicitWidth + ScreenTools.defaultFontPixelWidth * 0.5
            height: parent.height
            flat: true

            background: Rectangle {
                color: initConfigMenuBtn.hovered || initConfigMenu.visible ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: initConfigMenuBtn.text
                color: menuBtnText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Microsoft YaHei"
                visible: true
                opacity: 1
            }

            onClicked: {
                if (initConfigMenu.visible) {
                    initConfigMenu.close()
                } else {
                    var pos = initConfigMenuBtn.mapToItem(mainWindow.contentItem, 0, 0)
                    initConfigMenu.x = pos.x
                    initConfigMenu.y = pos.y + initConfigMenuBtn.height + 2
                    initConfigMenu.open()
                }
            }
        }

        // ===== 通讯菜单 =====
        QGCButton {
            id: commMenuBtn
            text: "通讯(C)"
            width: implicitWidth + ScreenTools.defaultFontPixelWidth * 0.5
            height: parent.height
            flat: true

            background: Rectangle {
                color: commMenuBtn.hovered || commMenu.visible ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: commMenuBtn.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Microsoft YaHei"
                visible: true
                opacity: 1
            }

            onClicked: {
                if (commMenu.visible) {
                    commMenu.close()
                } else {
                    var pos = commMenuBtn.mapToItem(mainWindow.contentItem, 0, 0)
                    commMenu.x = pos.x
                    commMenu.y = pos.y + commMenuBtn.height + 2
                    commMenu.open()
                }
            }
        }

        // ===== 控制菜单 =====
        QGCButton {
            id: controlMenuBtn
            text: "控制(O)"
            width: implicitWidth + ScreenTools.defaultFontPixelWidth * 0.5
            height: parent.height
            flat: true

            background: Rectangle {
                color: controlMenuBtn.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: controlMenuBtn.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Microsoft YaHei"
                visible: true
                opacity: 1
            }

            onClicked: {
                if (controlMenu.visible) {
                    controlMenu.close()
                } else {
                    var pos = controlMenuBtn.mapToItem(mainWindow.contentItem, 0, 0)
                    controlMenu.x = pos.x
                    controlMenu.y = pos.y + controlMenuBtn.height + 2
                    controlMenu.open()
                }
            }
        }

        // ===== 飞行准备菜单 =====
        QGCButton {
            id: flightOpMenuBtn
            text: "飞行准备(P)"
            width: implicitWidth + ScreenTools.defaultFontPixelWidth * 0.5
            height: parent.height
            flat: true

            background: Rectangle {
                color: flightOpMenuBtn.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: flightOpMenuBtn.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Microsoft YaHei"
                visible: true
                opacity: 1
            }

            onClicked: {
                if (flightOpMenu.visible) {
                    flightOpMenu.close()
                } else {
                    var pos = flightOpMenuBtn.mapToItem(mainWindow.contentItem, 0, 0)
                    flightOpMenu.x = pos.x
                    flightOpMenu.y = pos.y + flightOpMenuBtn.height + 2
                    flightOpMenu.open()
                }
            }
        }

        // ===== 航线菜单 =====
        QGCButton {
            id: airLineOpMenuBtn
            text: "航线(W)"
            width: implicitWidth + ScreenTools.defaultFontPixelWidth * 0.5
            height: parent.height
            flat: true

            background: Rectangle {
                color: airLineOpMenuBtn.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: airLineOpMenuBtn.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Microsoft YaHei"
                visible: true
                opacity: 1
            }

            onClicked: {
                if (airLineMenu.visible) {
                    airLineMenu.close()
                } else {
                    var pos = airLineOpMenuBtn.mapToItem(mainWindow.contentItem, 0, 0)
                    airLineMenu.x = pos.x
                    airLineMenu.y = pos.y + airLineOpMenuBtn.height + 2
                    airLineMenu.open()
                }
            }
        }

        // ===== 遥测菜单 =====
        QGCButton {
            id: telemeteOpMenuBtn
            text: "遥测(B)"
            width: implicitWidth + ScreenTools.defaultFontPixelWidth * 0.5
            height: parent.height
            flat: true

            background: Rectangle {
                color: telemeteOpMenuBtn.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: telemeteOpMenuBtn.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Microsoft YaHei"
                visible: true
                opacity: 1
            }

            onClicked: {
                if (telemetryMenu.visible) {
                    telemetryMenu.close()
                } else {
                    var pos = telemeteOpMenuBtn.mapToItem(mainWindow.contentItem, 0, 0)
                    telemetryMenu.x = pos.x
                    telemetryMenu.y = pos.y + telemeteOpMenuBtn.height + 2
                    telemetryMenu.open()
                }
            }
        }

        // ===== 遥控菜单 =====
        QGCButton {
            id: telecontrolOpMenuBtn
            text: "遥控(R)"
            width: implicitWidth + ScreenTools.defaultFontPixelWidth * 0.5
            height: parent.height
            flat: true

            background: Rectangle {
                color: telecontrolOpMenuBtn.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: telecontrolOpMenuBtn.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Microsoft YaHei"
                visible: true
                opacity: 1
            }

            onClicked: {
                if (telecontrolMenu.visible) {
                    telecontrolMenu.close()
                } else {
                    var pos = telecontrolOpMenuBtn.mapToItem(mainWindow.contentItem, 0, 0)
                    telecontrolMenu.x = pos.x
                    telecontrolMenu.y = pos.y + telecontrolOpMenuBtn.height + 2
                    telecontrolMenu.open()
                }
            }
        }

        // ===== 记录菜单 =====
        QGCButton {
            id: recordOpMenuBtn
            text: "记录(S)"
            width: implicitWidth + ScreenTools.defaultFontPixelWidth * 0.5
            height: parent.height
            flat: true

            background: Rectangle {
                color: recordOpMenuBtn.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: recordOpMenuBtn.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Microsoft YaHei"
                visible: true
                opacity: 1
            }

            onClicked: {
                if (recordMenu.visible) {
                    recordMenu.close()
                } else {
                    var pos = recordOpMenuBtn.mapToItem(mainWindow.contentItem, 0, 0)
                    recordMenu.x = pos.x
                    recordMenu.y = pos.y + recordOpMenuBtn.height + 2
                    recordMenu.open()
                }
            }
        }

        // ===== 载荷菜单 =====
        QGCButton {
            id: loadOpMenuBtn
            text: "载荷(P)"
            width: implicitWidth + ScreenTools.defaultFontPixelWidth * 0.5
            height: parent.height
            flat: true

            background: Rectangle {
                color: loadOpMenuBtn.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: loadOpMenuBtn.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Microsoft YaHei"
                visible: true
                opacity: 1
            }

            onClicked: {
                if (loadMenu.visible) {
                    loadMenu.close()
                } else {
                    var pos = loadOpMenuBtn.mapToItem(mainWindow.contentItem, 0, 0)
                    loadMenu.x = pos.x
                    loadMenu.y = pos.y + loadOpMenuBtn.height + 2
                    loadMenu.open()
                }
            }
        }

// ===== 配置菜单 =====
        QGCButton {
            id: deployOpMenuBtn
            text: "配置(D)"
            width: implicitWidth + ScreenTools.defaultFontPixelWidth * 0.5
            height: parent.height
            flat: true

            background: Rectangle {
                color: deployOpMenuBtn.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: deployOpMenuBtn.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Microsoft YaHei"
                visible: true
                opacity: 1
            }

            onClicked: {
                if (deployMenu.visible) {
                    deployMenu.close()
                } else {
                    var pos = deployOpMenuBtn.mapToItem(mainWindow.contentItem, 0, 0)
                    deployMenu.x = pos.x
                    deployMenu.y = pos.y + deployOpMenuBtn.height + 2
                    deployMenu.open()
                }
            }
        }
        // ===== 其他菜单 =====
        QGCButton {
            id: elseOpMenuBtn
            text: "其他(H)"
            width: implicitWidth + ScreenTools.defaultFontPixelWidth * 0.5
            height: parent.height
            flat: true

            background: Rectangle {
                color: elseOpMenuBtn.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: elseOpMenuBtn.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Microsoft YaHei"
                visible: true
                opacity: 1
            }

            onClicked: {
                if (otherMenu.visible) {
                    otherMenu.close()
                } else {
                    var pos = elseOpMenuBtn.mapToItem(mainWindow.contentItem, 0, 0)
                    otherMenu.x = pos.x
                    otherMenu.y = pos.y + elseOpMenuBtn.height + 2
                    otherMenu.open()
                }
            }
        }

        // ===== 设置菜单 =====
        QGCButton {
            id: settingsMenuBtn
            text: "设置(S)"
            width: implicitWidth + ScreenTools.defaultFontPixelWidth * 0.5
            height: parent.height
            flat: true

            background: Rectangle {
                color: settingsMenuBtn.hovered || settingsMenu.visible ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: settingsMenuBtn.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 9
                font.family: "Microsoft YaHei"
                visible: true
                opacity: 1
            }

            onClicked: {
                if (settingsMenu.visible) {
                    settingsMenu.close()
                } else {
                    var pos = settingsMenuBtn.mapToItem(mainWindow.contentItem, 0, 0)
                    settingsMenu.x = pos.x
                    settingsMenu.y = pos.y + settingsMenuBtn.height + 2
                    settingsMenu.open()
                }
            }
        }
    }

}
