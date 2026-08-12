import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

Rectangle {
    id: toolBarView
    width: parent.width
    height: parent.height
    color: qgcPal.window

    QGCPalette { id: qgcPal }

    // 主题感知颜色
    property color toolBarBackground:    qgcPal.window
    property color toolBtnBackground:    qgcPal.window
    property color toolBtnHover:         qgcPal.windowShadeLight
    property color toolBtnText:          qgcPal.text
    property color toolBtnActive:        qgcPal.globalTheme === QGCPalette.Light ? "#BBDEFB" : "#1E3A5F"
    property color toolBtnActiveBorder:  qgcPal.globalTheme === QGCPalette.Light ? "#1976D2" : "#4FC3F7"
    property color toolBtnBorder:        qgcPal.globalTheme === QGCPalette.Light ? "#C0C0C0" : "#555555"


    // 引用主窗口（由父组件传入）
    property var mainWindow: null

    Row {
        anchors.fill: parent
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.5
        spacing: ScreenTools.defaultFontPixelWidth * 0.2


        QGCButton {
            width: height
            height: parent.height
            flat: true
            ToolTip {
                text: "选择工具"
                visible: parent.hovered   // 鼠标悬停时显示
                delay: 500                // 悬停 500ms 后显示，避免误触
            }
            background: Rectangle {
                color: mainWindow.selectToolMode ? toolBtnActive : (parent.hovered ? toolBtnHover : toolBtnBackground)
                radius: 3
                border.color: mainWindow.selectToolMode ? toolBtnActiveBorder : toolBtnBorder
                border.width: mainWindow.selectToolMode ? 2 : 1
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Image {
                source: "/qmlimages/sorrowblue3.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 2   // 微小边距，防止图片紧贴按钮边缘
            }
            onClicked: {
                mainWindow.zoomOnClickMode = false
                mainWindow.zoomOutOnClickMode = false
                mainWindow.moveToolMode = false
                mainWindow.measureToolMode = false
                mainWindow.selectToolMode = true
            }
        }
        QGCButton {
            width: height
            height: parent.height
            flat: true
            ToolTip {
                text: "放大地图"
                visible: parent.hovered   // 鼠标悬停时显示
                delay: 500                // 悬停 500ms 后显示，避免误触
            }
            background: Rectangle {
                color: mainWindow.zoomOnClickMode ? toolBtnActive : (parent.hovered ? toolBtnHover : toolBtnBackground)
                radius: 3
                border.color: mainWindow.zoomOnClickMode ? toolBtnActiveBorder : toolBtnBorder
                border.width: mainWindow.zoomOnClickMode ? 2 : 1
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Image {
                source: "/qmlimages/zoomblue6.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 2   // 微小边距，防止图片紧贴按钮边缘
            }
            onClicked: {
                mainWindow.zoomOutOnClickMode = false
                mainWindow.selectToolMode = false
                mainWindow.moveToolMode = false
                mainWindow.measureToolMode = false
                mainWindow.zoomOnClickMode = !mainWindow.zoomOnClickMode
            }
        }
        QGCButton {
            width: height
            height: parent.height
            flat: true
            ToolTip {
                text: "缩小地图"
                visible: parent.hovered   // 鼠标悬停时显示
                delay: 500                // 悬停 500ms 后显示，避免误触
            }
            background: Rectangle {
                color: mainWindow.zoomOutOnClickMode ? toolBtnActive : (parent.hovered ? toolBtnHover : toolBtnBackground)
                radius: 3
                border.color: mainWindow.zoomOutOnClickMode ? toolBtnActiveBorder : toolBtnBorder
                border.width: mainWindow.zoomOutOnClickMode ? 2 : 1
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Image {
                source: "/qmlimages/reduceblue6.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 2   // 微小边距，防止图片紧贴按钮边缘
            }
            onClicked: {
                mainWindow.zoomOnClickMode = false
                mainWindow.selectToolMode = false
                mainWindow.moveToolMode = false
                mainWindow.measureToolMode = false
                mainWindow.zoomOutOnClickMode = !mainWindow.zoomOutOnClickMode
            }
        }
        QGCButton {
            width: height
            height: parent.height
            flat: true
            ToolTip {
                text: "移动地图"
                visible: parent.hovered   // 鼠标悬停时显示
                delay: 500                // 悬停 500ms 后显示，避免误触
            }
            background: Rectangle {
                color: mainWindow.moveToolMode ? toolBtnActive : (parent.hovered ? toolBtnHover : toolBtnBackground)
                radius: 3
                border.color: mainWindow.moveToolMode ? toolBtnActiveBorder : toolBtnBorder
                border.width: mainWindow.moveToolMode ? 2 : 1
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Image {
                source: "/qmlimages/handblue.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 2   // 微小边距，防止图片紧贴按钮边缘
            }
            onClicked: {
                mainWindow.selectToolMode = false
                mainWindow.zoomOnClickMode = false
                mainWindow.zoomOutOnClickMode = false
                mainWindow.measureToolMode = false
                mainWindow.moveToolMode = !mainWindow.moveToolMode
            }
        }
        QGCButton {
            width: height
            height: parent.height
            flat: true
            ToolTip {
                text: "擦除航迹"
                visible: parent.hovered   // 鼠标悬停时显示
                delay: 500                // 悬停 500ms 后显示，避免误触
            }
            background: Rectangle {
                color: parent.hovered ? toolBtnHover : toolBtnBackground
                radius: 3
                border.color: toolBtnBorder      // ← 添加边框
                border.width: 1              // ← 边框宽度
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Image {
                source: "/qmlimages/eraserblue6.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 2   // 微小边距，防止图片紧贴按钮边缘
            }

        }
        QGCButton {
            width: height
            height: parent.height
            flat: true
            ToolTip {
                text: "距离测量"
                visible: parent.hovered
                delay: 500
            }

            background: Rectangle {
                color: mainWindow.measureToolMode ? toolBtnActive : (parent.hovered ? toolBtnHover : toolBtnBackground)
                radius: 3
                border.color: mainWindow.measureToolMode ? toolBtnActiveBorder : toolBtnBorder
                border.width: mainWindow.measureToolMode ? 2 : 1
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Image {
                source: "/qmlimages/距离测量.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 2
            }
            onClicked: {
                mainWindow.selectToolMode = false
                mainWindow.zoomOnClickMode = false
                mainWindow.zoomOutOnClickMode = false
                mainWindow.moveToolMode = false
                mainWindow.measureToolMode = !mainWindow.measureToolMode
            }
        }
        QGCButton {
            width: height
            height: parent.height
            flat: true
            onClicked: mainWindow.showRoutePlan()
            ToolTip {
                text: "航线规划"
                visible: parent.hovered   // 鼠标悬停时显示
                delay: 500                // 悬停 500ms 后显示，避免误触
            }

            background: Rectangle {
                color: parent.hovered ? toolBtnHover : toolBtnBackground
                radius: 3
                border.color: toolBtnBorder      // ← 添加边框
                border.width: 1              // ← 边框宽度
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Image {
                source: "/qmlimages/航线规划.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 2   // 微小边距，防止图片紧贴按钮边缘
            }
        }
        QGCButton {
            width: height
            height: parent.height
            flat: true
            ToolTip {
                text: "显示航线"
                visible: parent.hovered   // 鼠标悬停时显示
                delay: 500                // 悬停 500ms 后显示，避免误触
            }

            background: Rectangle {
                color: parent.hovered ? toolBtnHover : toolBtnBackground
                radius: 3
                border.color: toolBtnBorder      // ← 添加边框
                border.width: 1              // ← 边框宽度
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Image {
                source: "/qmlimages/显示航线.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 2   // 微小边距，防止图片紧贴按钮边缘
            }
        }
        QGCButton {
            width: height
            height: parent.height
            flat: true
            ToolTip {
                text: "寻找飞机"
                visible: parent.hovered   // 鼠标悬停时显示
                delay: 500                // 悬停 500ms 后显示，避免误触
            }

            background: Rectangle {
                color: parent.hovered ? toolBtnHover : toolBtnBackground
                radius: 3
                border.color: toolBtnBorder      // ← 添加边框
                border.width: 1              // ← 边框宽度
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Image {
                source: "/qmlimages/寻找飞机.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 2   // 微小边距，防止图片紧贴按钮边缘
            }
        }
        QGCButton {
            width: height
            height: parent.height
            flat: true
            ToolTip {
                text: "跟踪飞机"
                visible: parent.hovered   // 鼠标悬停时显示
                delay: 500                // 悬停 500ms 后显示，避免误触
            }

            background: Rectangle {
                color: parent.hovered ? toolBtnHover : toolBtnBackground
                radius: 3
                border.color: toolBtnBorder      // ← 添加边框
                border.width: 1              // ← 边框宽度
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Image {
                source: "/qmlimages/物流跟踪飞机.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 2   // 微小边距，防止图片紧贴按钮边缘
            }
        }
        QGCButton {
            width: height
            height: parent.height
            flat: true
            ToolTip {
                text: "报警音"
                visible: parent.hovered   // 鼠标悬停时显示
                delay: 500                // 悬停 500ms 后显示，避免误触
            }

            background: Rectangle {
                color: parent.hovered ? toolBtnHover : toolBtnBackground
                radius: 3
                border.color: toolBtnBorder      // ← 添加边框
                border.width: 1              // ← 边框宽度
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Image {
                source: "/qmlimages/报警音-01.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 2   // 微小边距，防止图片紧贴按钮边缘
            }
        }
        QGCButton {
            width: height
            height: parent.height
            flat: true

            background: Rectangle {
                color: parent.hovered ? toolBtnHover : toolBtnBackground
                radius: 3
                border.color: toolBtnBorder      // ← 添加边框
                border.width: 1              // ← 边框宽度
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            contentItem: Image {
                source: "/qmlimages/controllerred6.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 2   // 微小边距，防止图片紧贴按钮边缘
            }
        }
    }
}