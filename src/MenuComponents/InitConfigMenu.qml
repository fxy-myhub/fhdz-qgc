import QtQuick 2.11
import QtQuick.Controls 2.4
import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

Menu {
    id: initConfigMenuPopup
    width: 150
    modal: false
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    y: 0

    property var mainWindowRef: null

    // 主题感知背景
    background: Rectangle {
        color: QGroundControl.globalPalette ? QGroundControl.globalPalette.window : "white"
        border.color: QGroundControl.globalPalette ? QGroundControl.globalPalette.windowShade : "#C0C0C0"
        border.width: 1
        radius: 3
    }

    MenuItem {
        text: "PWM通道配置"
        onTriggered: {          
            console.log("PWM通道配置")
            initConfigMenuPopup.close()
            if (mainWindowRef && mainWindowRef.showPWMConfig) {
                mainWindowRef.showPWMConfig()
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

    MenuItem {
        text: "串口功能配置"
        onTriggered: {
            console.log("串口功能配置")
            initConfigMenuPopup.close()
            if (mainWindowRef && mainWindowRef.showSerialConfig) {
                mainWindowRef.showSerialConfig()
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

    MenuItem {
        text: "传感器校准"
        onTriggered: {
            console.log("传感器校准")
            initConfigMenuPopup.close()
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
        text: "遥控器校准"
        onTriggered: {
            console.log("遥控器校准")
            initConfigMenuPopup.close()
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
        text: "参数"
        onTriggered: {
            console.log("参数")
            initConfigMenuPopup.close()
            if (mainWindowRef && mainWindowRef.showParameterDialog) {
                mainWindowRef.showParameterDialog()
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
    MenuItem {
        text: "飞控固件升级"
        onTriggered: {
            console.log("飞控固件升级")
            initConfigMenuPopup.close()
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
