import QtQuick 2.11
import QtQuick.Controls 2.4
import QGroundControl 1.0
import QGroundControl.Palette 1.0
import QGroundControl.Controls 1.0
import QGroundControl.ScreenTools 1.0

Rectangle {
    id: dataItem
    width: parent ? parent.width : 100
    height: ScreenTools.defaultFontPixelHeight * 2.0
    border.color: itemBorderColor
    border.width: 1
    radius: 2
    color: "transparent"

    QGCPalette { id: qgcPal }

    // ============ 主题模式（dayMode / nightMode）============
    // 通过 qgcPal.globalTheme 判断：Light = 白天模式，Dark = 夜间模式
    property bool dayMode: qgcPal.globalTheme === QGCPalette.Light

    // 数据项字体颜色
    property color itemTextColor:   dayMode ? "#000000" : "#FFFFFF"
    // 数据项边框色
    property color itemBorderColor: dayMode ? Qt.rgba(0, 0, 0, 0.25) : Qt.rgba(1, 1, 1, 0.25)

    property string label: ""
    property string value: "--"
    property string unit: ""

    // 单行显示："标签：值 单位"（放大、白色、加粗）
    Row {
        anchors.centerIn: parent
        spacing: ScreenTools.defaultFontPixelWidth * 0.15

        QGCLabel {
            text: dataItem.label + "："
            color: dataItem.itemTextColor
            font.pointSize: ScreenTools.smallFontPointSize * 1.7
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }
        QGCLabel {
            text: dataItem.value
            color: dataItem.itemTextColor
            font.pointSize: ScreenTools.smallFontPointSize * 1.7
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }
        QGCLabel {
            text: dataItem.unit
            color: dataItem.itemTextColor
            font.pointSize: ScreenTools.smallFontPointSize * 1.5
            font.bold: true
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1
            visible: dataItem.unit !== ""
        }
    }
}
