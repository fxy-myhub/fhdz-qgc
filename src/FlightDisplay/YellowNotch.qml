/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick 2.12
import QtQuick.Controls 2.4

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

/// @brief 黄色刘海组件
/// 位于地图顶部正中间，紧挨快捷按钮下方。
/// 主要功能：发送/显示飞控当前信息。
/// 宽度为屏幕宽度的三分之一，高度适中，类似手机"刘海"造型。
/// 目前为占位框架，后期通过 infoText 属性绑定飞控实时信息。
Item {
    id: _root

    // 后期飞控实时信息字符串，绑定后即可显示
    property string infoText: "飞控信息"

    // 刘海背景色（黄色）
    property color notchColor: "#FFC107"

    // 刘海高度（约为默认字体高度的 4.8 倍）
    property real notchHeight: ScreenTools.defaultFontPixelHeight * 4.0

    // 刘海圆角
    property real notchRadius: ScreenTools.defaultFontPixelHeight * 0.8

    // 刘海宽度：屏幕宽度的三分之一
    width: parent.width / 3
    height: notchHeight

    // 刘海主体
    Rectangle {
        id: notchBody
        anchors.fill: parent
        color: _root.notchColor
        radius: _root.notchRadius
        border.color: Qt.darker(_root.notchColor, 1.2)
        border.width: 1

        // 刘海内文字（当前为占位，后期绑定飞控实时信息）
        QGCLabel {
            id: infoLabel
            anchors.centerIn: parent
            text: _root.infoText
            color: "#333333"
            font.family: "Microsoft YaHei"
            font.bold: true
            font.pixelSize: ScreenTools.defaultFontPixelHeight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
