/****************************************************************************
 *
 * FH Instrument Widget - EADI wrapper for QGC
 *
 * 将 EADI 电子姿态方向指示器与 QGroundControl 的 Vehicle 数据绑定
 *
 ****************************************************************************/

import QtQuick 2.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0

Item {
    id: root

    // 必须设置高度，否则 Loader 高度为 0，EADI 不可见
    // EADI 是 300x300 正方形，高度跟随宽度
    height: width

    property var missionController

    // 获取当前活跃飞行器
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    // 从 Vehicle 实时绑定飞行数据
    property real _pitch:     _activeVehicle ? _activeVehicle.pitch.rawValue            : 0         //俯仰角
    property real _roll:      _activeVehicle ? _activeVehicle.roll.rawValue             : 0         //翻滚角
    property real _heading:   _activeVehicle ? _activeVehicle.heading.rawValue          : 0         //航向  
    property real _airspeed:  _activeVehicle ? _activeVehicle.airSpeed.rawValue         : 0         //空速
    property real _altitude:  _activeVehicle ? _activeVehicle.altitudeRelative.rawValue : 0         //相对高度
    property real _climbRate: _activeVehicle ? _activeVehicle.climbRate.rawValue        : 0         //爬升率

    // 根据可用宽度计算缩放比例（EADI 基准尺寸为 300x300，height=width 保证正方形）
    property real _scale: width / 300

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    //仪表盘背景容器 - 跟随 root 宽度，保证与缩放后的 EADI 一致
    Rectangle {
        anchors.centerIn: parent
        width:  root.width
        height: root.height
        radius: 8
        color:  qgcPal.window
        border.color: qgcPal.text
        border.width: 1

        // 拦截点击事件，防止穿透到下层地图
        DeadMouseArea { anchors.fill: parent }
    }

    // EADI 主组件 - 保持 300x300 基准尺寸，通过 scale 整体缩放以适配不同分辨率
    ElectronicAttitudeDirectionIndicator {
        id: eadi
        anchors.centerIn: parent
        width:  300         // 基准尺寸
        height: 300         // 基准尺寸
        scale:  root._scale // 整体缩放，使仪表盘随容器宽度放大/缩小
        transformOrigin: Item.Center

        // 数据绑定到子组件
        adi.pitch:  _pitch
        adi.roll:   _roll
        hsi.heading: _heading
        asi.airspeed: _airspeed
        alt.altitude: _altitude
        vsi.climbRate: _climbRate
    }
}


