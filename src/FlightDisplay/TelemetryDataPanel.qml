import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.FactSystem 1.0
import QGroundControl.Palette 1.0

Rectangle {
    id: telemetryPanel
    width: parent.width
    height: 280  // 可以根据需要调整高度
    //color: Qt.rgba(0.05, 0.05, 0.08, 0.92)
    radius: 4
    //border.color: Qt.rgba(0.2, 0.3, 0.5, 0.3)
    border.width: 1

    QGCPalette { id: qgcPal }

    // ============ 主题模式（dayMode / nightMode）============
    // 通过 qgcPal.globalTheme 判断：Light = 白天模式，Dark = 夜间模式
    property bool dayMode: qgcPal.globalTheme === QGCPalette.Light

    // 面板背景色
    property color panelBackgroundColor: dayMode ? Qt.rgba(0.95, 0.95, 0.97, 0.95) : Qt.rgba(0.05, 0.05, 0.08, 0.92)
    // 面板边框色
    property color panelBorderColor:     dayMode ? Qt.rgba(0.2, 0.3, 0.5, 0.4)      : Qt.rgba(0.2, 0.3, 0.5, 0.3)
    // 列标题颜色
    property color titleColor:           dayMode ? "#1565C0"                        : "#4FC3F7"
    property color cmdTitleColor:        dayMode ? "#E65100"                        : "#FFD54F"
    property color fbTitleColor:         dayMode ? "#2E7D32"                        : "#81C784"
    // 切换按钮文字颜色
    property color toggleTextColor:      dayMode ? "#000000"                        : "#FFFFFF"

    color: panelBackgroundColor
    border.color: panelBorderColor

    property var vehicle: QGroundControl.multiVehicleManager.activeVehicle

    // 是否显示控制信息
    property bool showControls: true

    // 切换显示控制信息的按钮
    Rectangle {
        id: toggleButton
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 4
        width: 80
        height: 22
        color: showControls ? Qt.rgba(0.2, 0.6, 0.2, 0.6) : Qt.rgba(0.4, 0.4, 0.4, 0.6)
        radius: 3
        z: 10

        Text {
            anchors.centerIn: parent
            text: showControls ? "控制信息 ▲" : "控制信息 ▼"
            color: telemetryPanel.toggleTextColor
            font.pixelSize: 10
            font.family: "Open Sans"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                showControls = !showControls
                // 调整高度
                if (showControls) {
                    parent.parent.height = 280
                } else {
                    parent.parent.height = 160
                }
            }
        }
    }

    GridLayout {
        id: gridLayout
        anchors.fill: parent
        anchors.margins: 8
        anchors.topMargin: 32
        columns: 5  // 5列布局：标签、指令值、反馈值、分隔、下一组
        rowSpacing: 3
        columnSpacing: 4

        // ============ 列标题 ============
        Text {
            text: "参数"
            color: telemetryPanel.titleColor
            font.pixelSize: 11
            font.bold: true
            font.family: "Open Sans"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 50
        }
        Text {
            text: "[指令]"
            color: telemetryPanel.cmdTitleColor
            font.pixelSize: 11
            font.bold: true
            font.family: "Open Sans"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 48
        }
        Text {
            text: "[反馈]"
            color: telemetryPanel.fbTitleColor
            font.pixelSize: 11
            font.bold: true
            font.family: "Open Sans"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 48
        }
        Item { Layout.preferredWidth: 10 }
        Text {
            text: "控制信息"
            color: telemetryPanel.titleColor
            font.pixelSize: 11
            font.bold: true
            font.family: "Open Sans"
            visible: showControls
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 50
        }

        // 行1：迎角 / 左副翼
        TelemetryDataRow {
            Layout.column: 0
            label: "迎角"
            cmdValue: vehicle ? vehicle.angleOfAttackCmd : 0
            fbValue: vehicle ? vehicle.angleOfAttack : 0
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.angleOfAttackCmd : 0
            fbValue: vehicle ? vehicle.angleOfAttack : 0
            isValue: true
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.angleOfAttackCmd : 0
            fbValue: vehicle ? vehicle.angleOfAttack : 0
            isValue: true
        }
        Item { Layout.column: 3 }
        TelemetryDataRow {
            Layout.column: 4
            label: "左副翼"
            cmdValue: vehicle ? vehicle.leftAileronCmd : 0
            fbValue: vehicle ? vehicle.leftAileron : 0
            visible: showControls
        }

        // 行2：侧滑角 / 右副翼
        TelemetryDataRow {
            Layout.column: 0
            label: "侧滑角"
            cmdValue: vehicle ? vehicle.sideslipCmd : 0
            fbValue: vehicle ? vehicle.sideslip : 0
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.sideslipCmd : 0
            fbValue: vehicle ? vehicle.sideslip : 0
            isValue: true
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.sideslipCmd : 0
            fbValue: vehicle ? vehicle.sideslip : 0
            isValue: true
        }
        Item { Layout.column: 3 }
        TelemetryDataRow {
            Layout.column: 4
            label: "右副翼"
            cmdValue: vehicle ? vehicle.rightAileronCmd : 0
            fbValue: vehicle ? vehicle.rightAileron : 0
            visible: showControls
        }

        // 行3：俯仰角 / 左平尾
        TelemetryDataRow {
            Layout.column: 0
            label: "俯仰角"
            cmdValue: vehicle ? vehicle.pitchCmd : 0
            fbValue: vehicle ? vehicle.pitch : 0
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.pitchCmd : 0
            fbValue: vehicle ? vehicle.pitch : 0
            isValue: true
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.pitchCmd : 0
            fbValue: vehicle ? vehicle.pitch : 0
            isValue: true
        }
        Item { Layout.column: 3 }
        TelemetryDataRow {
            Layout.column: 4
            label: "左平尾"
            cmdValue: vehicle ? vehicle.leftElevatorCmd : 0
            fbValue: vehicle ? vehicle.leftElevator : 0
            visible: showControls
        }

        // 行4：滚转角 / 右平尾
        TelemetryDataRow {
            Layout.column: 0
            label: "滚转角"
            cmdValue: vehicle ? vehicle.rollCmd : 0
            fbValue: vehicle ? vehicle.roll : 0
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.rollCmd : 0
            fbValue: vehicle ? vehicle.roll : 0
            isValue: true
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.rollCmd : 0
            fbValue: vehicle ? vehicle.roll : 0
            isValue: true
        }
        Item { Layout.column: 3 }
        TelemetryDataRow {
            Layout.column: 4
            label: "右平尾"
            cmdValue: vehicle ? vehicle.rightElevatorCmd : 0
            fbValue: vehicle ? vehicle.rightElevator : 0
            visible: showControls
        }

        // 行5：航向角 / 方向舵
        TelemetryDataRow {
            Layout.column: 0
            label: "航向角"
            cmdValue: vehicle ? vehicle.headingCmd : 0
            fbValue: vehicle ? vehicle.heading : 0
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.headingCmd : 0
            fbValue: vehicle ? vehicle.heading : 0
            isValue: true
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.headingCmd : 0
            fbValue: vehicle ? vehicle.heading : 0
            isValue: true
        }
        Item { Layout.column: 3 }
        TelemetryDataRow {
            Layout.column: 4
            label: "方向舵"
            cmdValue: vehicle ? vehicle.rudderCmd : 0
            fbValue: vehicle ? vehicle.rudder : 0
            visible: showControls
        }

        // 行6：海拔m / 前轮
        TelemetryDataRow {
            Layout.column: 0
            label: "海拔m"
            cmdValue: vehicle ? vehicle.altitudeCmd : 0
            fbValue: vehicle ? vehicle.altitude : 0
            decimals: 2
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.altitudeCmd : 0
            fbValue: vehicle ? vehicle.altitude : 0
            isValue: true
            decimals: 2
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.altitudeCmd : 0
            fbValue: vehicle ? vehicle.altitude : 0
            isValue: true
            decimals: 2
        }
        Item { Layout.column: 3 }
        TelemetryDataRow {
            Layout.column: 4
            label: "前轮"
            cmdValue: vehicle ? vehicle.noseWheelCmd : 0
            fbValue: vehicle ? vehicle.noseWheel : 0
            visible: showControls
        }

        // 行7：气压高度 / 油门
        TelemetryDataRow {
            Layout.column: 0
            label: "气压高度"
            cmdValue: vehicle ? vehicle.baroAltCmd : 0
            fbValue: vehicle ? vehicle.baroAlt : 0
            decimals: 2
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.baroAltCmd : 0
            fbValue: vehicle ? vehicle.baroAlt : 0
            isValue: true
            decimals: 2
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.baroAltCmd : 0
            fbValue: vehicle ? vehicle.baroAlt : 0
            isValue: true
            decimals: 2
        }
        Item { Layout.column: 3 }
        TelemetryDataRow {
            Layout.column: 4
            label: "油门"
            cmdValue: vehicle ? vehicle.throttleCmd : 0
            fbValue: vehicle ? vehicle.throttle : 0
            visible: showControls
            decimals: 1
            unit: "%"
        }

        // 行8：马赫数 / (空)
        TelemetryDataRow {
            Layout.column: 0
            label: "马赫数"
            cmdValue: vehicle ? vehicle.machCmd : 0
            fbValue: vehicle ? vehicle.mach : 0
            decimals: 3
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.machCmd : 0
            fbValue: vehicle ? vehicle.mach : 0
            isValue: true
            decimals: 3
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.machCmd : 0
            fbValue: vehicle ? vehicle.mach : 0
            isValue: true
            decimals: 3
        }
        Item { Layout.column: 3 }
        Item { Layout.column: 4 }

        // 行9：爬升率
        TelemetryDataRow {
            Layout.column: 0
            label: "爬升率"
            cmdValue: vehicle ? vehicle.climbRateCmd : 0
            fbValue: vehicle ? vehicle.climbRate : 0
            decimals: 2
            unit: "m/s"
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.climbRateCmd : 0
            fbValue: vehicle ? vehicle.climbRate : 0
            isValue: true
            decimals: 2
            unit: "m/s"
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.climbRateCmd : 0
            fbValue: vehicle ? vehicle.climbRate : 0
            isValue: true
            decimals: 2
            unit: "m/s"
        }

        // 行10：地速
        TelemetryDataRow {
            Layout.column: 0
            label: "地速"
            cmdValue: vehicle ? vehicle.groundSpeedCmd : 0
            fbValue: vehicle ? vehicle.groundSpeed : 0
            decimals: 2
            unit: "m/s"
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.groundSpeedCmd : 0
            fbValue: vehicle ? vehicle.groundSpeed : 0
            isValue: true
            decimals: 2
            unit: "m/s"
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.groundSpeedCmd : 0
            fbValue: vehicle ? vehicle.groundSpeed : 0
            isValue: true
            decimals: 2
            unit: "m/s"
        }

        // 行11：表速
        TelemetryDataRow {
            Layout.column: 0
            label: "表速"
            cmdValue: vehicle ? vehicle.iasCmd : 0
            fbValue: vehicle ? vehicle.ias : 0
            decimals: 2
            unit: "m/s"
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.iasCmd : 0
            fbValue: vehicle ? vehicle.ias : 0
            isValue: true
            decimals: 2
            unit: "m/s"
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.iasCmd : 0
            fbValue: vehicle ? vehicle.ias : 0
            isValue: true
            decimals: 2
            unit: "m/s"
        }

        // 行12：真速
        TelemetryDataRow {
            Layout.column: 0
            label: "真速"
            cmdValue: vehicle ? vehicle.tasCmd : 0
            fbValue: vehicle ? vehicle.tas : 0
            decimals: 2
            unit: "m/s"
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.tasCmd : 0
            fbValue: vehicle ? vehicle.tas : 0
            isValue: true
            decimals: 2
            unit: "m/s"
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.tasCmd : 0
            fbValue: vehicle ? vehicle.tas : 0
            isValue: true
            decimals: 2
            unit: "m/s"
        }

        // 行13：动压
        TelemetryDataRow {
            Layout.column: 0
            label: "动压"
            cmdValue: vehicle ? vehicle.dynamicPressureCmd : 0
            fbValue: vehicle ? vehicle.dynamicPressure : 0
            decimals: 2
            unit: "Pa"
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.dynamicPressureCmd : 0
            fbValue: vehicle ? vehicle.dynamicPressure : 0
            isValue: true
            decimals: 2
            unit: "Pa"
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.dynamicPressureCmd : 0
            fbValue: vehicle ? vehicle.dynamicPressure : 0
            isValue: true
            decimals: 2
            unit: "Pa"
        }

        // 行14：下滑角
        TelemetryDataRow {
            Layout.column: 0
            label: "下滑角"
            cmdValue: vehicle ? vehicle.glideSlopeCmd : 0
            fbValue: vehicle ? vehicle.glideSlope : 0
            decimals: 2
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.glideSlopeCmd : 0
            fbValue: vehicle ? vehicle.glideSlope : 0
            isValue: true
            decimals: 2
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.glideSlopeCmd : 0
            fbValue: vehicle ? vehicle.glideSlope : 0
            isValue: true
            decimals: 2
        }

        // 行15：侧偏距
        TelemetryDataRow {
            Layout.column: 0
            label: "侧偏距"
            cmdValue: vehicle ? vehicle.crossTrackCmd : 0
            fbValue: vehicle ? vehicle.crossTrack : 0
            decimals: 2
            unit: "m"
        }
        TelemetryDataRow {
            Layout.column: 1
            cmdValue: vehicle ? vehicle.crossTrackCmd : 0
            fbValue: vehicle ? vehicle.crossTrack : 0
            isValue: true
            decimals: 2
            unit: "m"
        }
        TelemetryDataRow {
            Layout.column: 2
            cmdValue: vehicle ? vehicle.crossTrackCmd : 0
            fbValue: vehicle ? vehicle.crossTrack : 0
            isValue: true
            decimals: 2
            unit: "m"
        }
    }
}