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
    y: 0  // 由 onClicked 中的位置计算控制

    // 主题感知背景
    background: Rectangle {
        color: QGroundControl.globalPalette ? QGroundControl.globalPalette.window : "white"
        border.color: QGroundControl.globalPalette ? QGroundControl.globalPalette.windowShade : "#C0C0C0"
        border.width: 1
        radius: 3
    }
    // Menu 自带背景，不需要 DropShadow

    property var mainWindowRef: null

    // property var finishCloseProcess: null
    MenuItem {
        text: "下载"
        onTriggered: {
            console.log("下载")
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
        text: "回放"
        onTriggered: {
            console.log("回放")
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
        text: "日志信息"
        onTriggered: {
            console.log("日志信息")
            fileMenuPopup.close()
            if (mainWindowRef && mainWindowRef.showLogDialog) {
                mainWindowRef.showLogDialog()
            }
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
