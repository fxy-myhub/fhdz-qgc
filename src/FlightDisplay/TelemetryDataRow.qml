import QtQuick 2.12
import QtQuick.Controls 2.12
import QGroundControl.Palette 1.0

// 单行数据组件 - 用于 GridLayout 中
Item {
    id: root

    property string label: ""
    property real cmdValue: 0
    property real fbValue: 0
    property int decimals: 2
    property string unit: ""
    property bool isValue: false  // true 表示只显示数值，false 表示显示标签

    QGCPalette { id: qgcPal }

    // ============ 主题模式（dayMode / nightMode）============
    // 通过 qgcPal.globalTheme 判断：Light = 白天模式，Dark = 夜间模式
    property bool dayMode: qgcPal.globalTheme === QGCPalette.Light

    // 标签文字颜色
    property color labelColor:      dayMode ? "#000000" : "#FFFFFF"
    // 数值框背景色
    property color valueBoxColor:   dayMode ? Qt.rgba(0.9, 0.9, 0.92, 0.9) : Qt.rgba(0.15, 0.15, 0.2, 0.8)
    // 数值框边框色
    property color valueBoxBorder:  dayMode ? Qt.rgba(0.3, 0.3, 0.4, 0.4)  : Qt.rgba(0.3, 0.3, 0.4, 0.3)
    // 指令值文字颜色
    property color cmdValueColor:   dayMode ? "#E65100" : "#FFD54F"
    // 反馈值文字颜色
    property color fbValueColor:    dayMode ? "#2E7D32" : "#81C784"

    implicitHeight: 20
    implicitWidth: isValue ? 52 : 48

    // 如果是标签列
    Text {
        anchors.fill: parent
        visible: !isValue
        text: root.label
        color: root.labelColor
        font.pixelSize: 10
        font.family: "Open Sans"
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // 如果是数值列（指令值）
    Rectangle {
        anchors.fill: parent
        visible: isValue
        color: root.valueBoxColor
        radius: 2
        border.color: root.valueBoxBorder
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: {
                var val = (parent.parent === cmdContainer) ? root.cmdValue : root.fbValue
                return val.toFixed(root.decimals) + (root.unit ? " " + root.unit : "")
            }
            color: (parent.parent === cmdContainer) ? root.cmdValueColor : root.fbValueColor
            font.pixelSize: 10
            font.family: "Open Sans"
            font.bold: true
        }
    }
}