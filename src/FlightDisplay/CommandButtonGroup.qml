/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGC is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.12
import QtQuick.Controls         2.4
import QtQuick.Layouts          1.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0

// 底部中间命令按钮组
// 每个按钮独立定义，各自拥有独立功能
Rectangle {
    id: _root

    QGCPalette { id: qgcPal }

    // ============ 主题模式（dayMode / nightMode）============
    // 通过 qgcPal.globalTheme 判断：Light = 白天模式，Dark = 夜间模式
    property bool dayMode: qgcPal.globalTheme === QGCPalette.Light

    // 背景色（与主题绑定）
    property color panelBackgroundColor: dayMode ? Qt.rgba(0.95, 0.95, 0.97, 0.95) : Qt.rgba(0.05, 0.05, 0.08, 0.92)
    // 边框色（与主题绑定）
    property color panelBorderColor:     dayMode ? Qt.rgba(0.2, 0.3, 0.5, 0.4)      : Qt.rgba(0.2, 0.3, 0.5, 0.4)

    // 主题感知颜色（与 MenuBarView.qml 一致）
    property color menuBtnBackground:    qgcPal.window
    property color menuBtnHover:         qgcPal.windowShadeLight
    property color menuBtnText:          qgcPal.text

    // 按钮字体大小（自适应屏幕尺寸/分辨率，方便统一修改）
    property real buttonFontPointSize:   ScreenTools.defaultFontPointSize * 1.6

    // 按钮宽度额外增量（在按钮自身隐式宽度基础上增加，方便统一修改）
    property real buttonWidthExtra:  ScreenTools.defaultFontPixelWidth * 5
    // 按钮高度（自适应屏幕尺寸/分辨率，方便统一修改）
    property real buttonHeight:      ScreenTools.defaultFontPixelHeight * 1.8



    color: panelBackgroundColor
    radius: 3
    border.color: panelBorderColor
    border.width: 1

    implicitWidth: buttonRow.implicitWidth + ScreenTools.defaultFontPixelWidth * 5
    implicitHeight: buttonRow.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.5

    RowLayout {
        id: buttonRow
        anchors.fill: parent
        anchors.margins: ScreenTools.defaultFontPixelWidth * 0.5
        spacing: ScreenTools.defaultFontPixelWidth * 0.5

        // ===== 点火 =====
        QGCButton {
            id: ignitionButton
            text: "点火"
            Layout.preferredWidth: implicitWidth + buttonWidthExtra
            Layout.preferredHeight: buttonHeight
            flat: true


            background: Rectangle {
                color: ignitionButton.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: ignitionButton.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: _root.buttonFontPointSize
                font.family: "Microsoft YaHei"

                visible: true
                opacity: 1
            }

            onClicked: {
                console.log(text)
            }
        }

        // ===== 熄火 =====
        QGCButton {
            id: flameoutButton
            text: "熄火"
            Layout.preferredWidth: implicitWidth + buttonWidthExtra
            Layout.preferredHeight: buttonHeight
            flat: true


            background: Rectangle {
                color: flameoutButton.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: flameoutButton.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: _root.buttonFontPointSize
                font.family: "Microsoft YaHei"

                visible: true
                opacity: 1
            }

            onClicked: {
                console.log(text)
            }
        }

        // ===== 开伞 =====
        QGCButton {
            id: parachuteButton
            text: "开伞"
            Layout.preferredWidth: implicitWidth + buttonWidthExtra
            Layout.preferredHeight: buttonHeight
            //Layout.preferredHeight: parent.height
            flat: true


            background: Rectangle {
                color: parachuteButton.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: parachuteButton.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: _root.buttonFontPointSize
                font.family: "Microsoft YaHei"

                visible: true
                opacity: 1
            }

            onClicked: {
                console.log(text)
            }
        }

        // ===== 盘旋 =====
        QGCButton {
            id: hoverButton
            text: "盘旋"
            Layout.preferredWidth: implicitWidth + buttonWidthExtra
            Layout.preferredHeight: buttonHeight
            flat: true


            background: Rectangle {
                color: hoverButton.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: hoverButton.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: _root.buttonFontPointSize
                font.family: "Microsoft YaHei"

                visible: true
                opacity: 1
            }

            onClicked: {
                console.log(text)
            }
        }

        // ===== 归航 =====
        QGCButton {
            id: returnButton
            text: "归航"
            Layout.preferredWidth: implicitWidth + buttonWidthExtra
            Layout.preferredHeight: buttonHeight
            flat: true


            background: Rectangle {
                color: returnButton.hovered ? menuBtnHover : menuBtnBackground
                radius: 3
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: QGCLabel {
                text: returnButton.text
                color: menuBtnText

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: _root.buttonFontPointSize
                font.family: "Microsoft YaHei"

                visible: true
                opacity: 1
            }

            onClicked: {
                console.log(text)
            }
        }
    }
}
