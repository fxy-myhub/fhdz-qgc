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
        color: QGroundControl.globalPalette ? QGroundControl.globalPalette.window : "white"     //三元判断 ? palette.xxx : 硬编码，防 null 崩溃,palette 不可用时 fallback 到硬编码的 "white"
        border.color: QGroundControl.globalPalette ? QGroundControl.globalPalette.windowShade : "#C0C0C0"       //边框阴影色（比 window 稍深一点，用来做立体感）
        border.width: 1
        radius: 3
    }

    // 主窗口引用，用于打开主题设置弹窗
    property var mainWindowRef: null

    MenuItem {
        text: "主题设置"
        onTriggered: {
            console.log("主题设置")
            fileMenuPopup.close()
            if (mainWindowRef) {
                mainWindowRef.showThemeSettings()
            }
        }
        background: Rectangle {
            //多了一层逻辑——根据 parent.highlighted 状态切换
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
