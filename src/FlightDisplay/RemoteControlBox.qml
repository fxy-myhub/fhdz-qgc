import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.ScreenTools 1.0

Rectangle {
    id: remoteControlBox
    color: "white"
    radius: 3
    border.color: Qt.rgba(0, 0, 0, 0.12)
    border.width: 1

    property var activeVehicle: null
    property var missionController: null
    property var guidedController: null

    // 按钮点击信号
    signal buttonClicked(string buttonName)

    GridLayout {
        id: buttonGrid
        anchors.fill: parent
        anchors.margins: ScreenTools.defaultFontPixelWidth * 0.5
        columns: 3
        rowSpacing: ScreenTools.defaultFontPixelHeight * 0.1
        columnSpacing: ScreenTools.defaultFontPixelWidth * 0.15

        // ===== 第1行 =====
        Rectangle {
            Layout.fillWidth: true          //按钮宽度填满所在列
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4    //按钮高度=字体高度*1.4
            radius: 4
            color: mouseArea1.containsMouse ? "#E3F2FD" : "#E0E0E0"  // 背景色：三目运算符判断鼠标是否悬停
            border.color: mouseArea1.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12) // 边框颜色：同样根据悬停状态变化
            border.width: mouseArea1.containsMouse ? 2 : 1     //  悬停时边框加粗

            QGCLabel {
                anchors.centerIn: parent    // 文字在按钮中居中显示
                text: "解锁"
                color: mouseArea1.containsMouse ? "#1565C0" : "black"  // 文字颜色：悬停时深蓝色，否则黑色
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true             // 文字加粗
                horizontalAlignment: Text.AlignHCenter  // 水平居中
                verticalAlignment: Text.AlignVCenter    // 垂直居中
            }

            MouseArea {
                id: mouseArea1
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor              // 鼠标悬停时变为手型指针
                onClicked: remoteControlBox.buttonClicked("解锁")      // 点击时发射信号
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea2.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea2.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea2.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "上锁"
                color: mouseArea2.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea2
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("上锁")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea3.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea3.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea3.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "起飞"
                color: mouseArea3.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea3
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("起飞")
            }
        }

        // ===== 第2行 =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea4.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea4.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea4.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "降落"
                color: mouseArea4.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea4
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("降落")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea5.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea5.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea5.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "返航"
                color: mouseArea5.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea5
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("返航")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea6.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea6.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea6.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "悬停"
                color: mouseArea6.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea6
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("悬停")
            }
        }

        // ===== 第3行 =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea7.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea7.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea7.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "定高"
                color: mouseArea7.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea7
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("定高")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea8.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea8.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea8.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "悬停点"
                color: mouseArea8.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea8
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("悬停点")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea9.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea9.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea9.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "自稳"
                color: mouseArea9.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea9
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("自稳")
            }
        }

        // ===== 第4行 =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea10.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea10.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea10.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "特技"
                color: mouseArea10.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea10
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("特技")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea11.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea11.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea11.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "开始任务"
                color: mouseArea11.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea11
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked:remoteControlBox.buttonClicked("开始任务")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea12.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea12.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea12.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "停止任务"
                color: mouseArea12.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea12
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("停止任务")
            }
        }

        // ===== 第5行 =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea13.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea13.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea13.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "暂停"
                color: mouseArea13.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea13
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("暂停")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea14.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea14.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea14.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "自动模式"
                color: mouseArea14.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea14
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("自动模式")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea15.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea15.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea15.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "RTL返航"
                color: mouseArea15.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea15
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("RTL返航")
            }
        }

        // ===== 第6行 =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea16.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea16.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea16.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "拍照"
                color: mouseArea16.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea16
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("拍照")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea17.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea17.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea17.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "紧急停止"
                color: mouseArea17.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea17
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("紧急停止")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea18.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea18.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea18.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "舵机测试"
                color: mouseArea18.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea18
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("舵机测试")
            }
        }

        // ===== 第7行 =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea19.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea19.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea19.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "重置原点"
                color: mouseArea19.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea19
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("重置原点")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: mouseArea20.containsMouse ? "#E3F2FD" : "#E0E0E0"
            border.color: mouseArea20.containsMouse ? "#2196F3" : Qt.rgba(0, 0, 0, 0.12)
            border.width: mouseArea20.containsMouse ? 2 : 1

            QGCLabel {
                anchors.centerIn: parent
                text: "引导模式"
                color: mouseArea20.containsMouse ? "#1565C0" : "black"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: mouseArea20
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: remoteControlBox.buttonClicked("引导模式")
            }
        }

        // 占位空白，保持3列布局完整
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.6
        }
    }
}