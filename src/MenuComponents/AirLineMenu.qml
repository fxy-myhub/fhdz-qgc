import QtQuick 2.11
import QtQuick.Controls 2.4
import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

Menu {
    id: fileMenuPopup
    width: 150
    modal: false
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    y: 0

    // 主题感知背景
    background: Rectangle {
        color: QGroundControl.globalPalette ? QGroundControl.globalPalette.window : "white"
        border.color: QGroundControl.globalPalette ? QGroundControl.globalPalette.windowShade : "#C0C0C0"
        border.width: 1
        radius: 3
    }
    property var mainWindow: null

    MenuItem {
        text: "航线规划"
        onTriggered: {
            if (mainWindow) {
                mainWindow.showRoutePlan()
            }
            fileMenuPopup.close()
        }
        background: Rectangle {
            color: parent.highlighted ? (QGroundControl.globalPalette ? QGroundControl.globalPalette.windowShadeLight : "#E0E0E0") : "transparent"
            radius: 3
        }
        contentItem: QGCLabel {
            text: parent.text
            color: QGroundControl.globalPalette ? QGroundControl.globalPalette.text : "black"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 9
            font.family: "Microsoft YaHei"
        }
    }

    MenuItem {
        text: "撤销航电操作"
        onTriggered: {
            console.log("撤销航电操作")
            fileMenuPopup.close()
        }
        background: Rectangle {
            color: parent.highlighted ? (QGroundControl.globalPalette ? QGroundControl.globalPalette.windowShadeLight : "#E0E0E0") : "transparent"
            radius: 3
        }
        contentItem: QGCLabel {
            text: parent.text
            color: QGroundControl.globalPalette ? QGroundControl.globalPalette.text : "black"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 9
            font.family: "Microsoft YaHei"
        }
    }

    MenuItem {
        text: "恢复航点操作"
        onTriggered: {
            console.log("恢复航点操作")
            fileMenuPopup.close()
        }
        background: Rectangle {
            color: parent.highlighted ? (QGroundControl.globalPalette ? QGroundControl.globalPalette.windowShadeLight : "#E0E0E0") : "transparent"
            radius: 3
        }
        contentItem: QGCLabel {
            text: parent.text
            color: QGroundControl.globalPalette ? QGroundControl.globalPalette.text : "black"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 9
            font.family: "Microsoft YaHei"
        }
    }

}