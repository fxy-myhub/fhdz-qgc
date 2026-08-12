import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

import QGroundControl 1.0
import QGroundControl.Palette 1.0
import QGroundControl.Controls 1.0
import QGroundControl.ScreenTools 1.0

Rectangle {
    id: serialConnectBar

    QGCPalette { id: qgcPal }

    // ============ 主题模式（dayMode / nightMode）============
    // 通过 qgcPal.globalTheme 判断：Light = 白天模式，Dark = 夜间模式
    property bool dayMode: qgcPal.globalTheme === QGCPalette.Light

    // 背景色（与主题绑定）
    property color panelBackgroundColor: dayMode ? Qt.rgba(0.95, 0.95, 0.97, 0.95) : Qt.rgba(0.05, 0.05, 0.08, 0.92)
    // 边框色（与主题绑定）
    property color panelBorderColor:     dayMode ? Qt.rgba(0, 0, 0, 0.12)          : Qt.rgba(1, 1, 1, 0.25)

    color: panelBackgroundColor
    radius: 3
    border.color: panelBorderColor
    border.width: 1

    implicitWidth: ScreenTools.defaultFontPixelWidth * 36
    implicitHeight: ScreenTools.defaultFontPixelHeight * 2.2

    // 当前串口配置
    property var _currentConfig: null
    property bool _isConnected: _currentConfig && _currentConfig.link !== null

    // 定时刷新串口列表
    Timer {
        id: portRefreshTimer
        interval: 2000
        running: !_isConnected && serialConnectBar.visible
        repeat: true
        onTriggered: refreshPortList()
    }

    // 刷新串口列表并保持当前选中项
    function refreshPortList() {
        var portStrings = QGroundControl.linkManager.serialPortStrings
        if (portStrings.length === 0) {
            portCombo.model = ["无可用串口"]
            portCombo.currentIndex = 0
            portCombo.enabled = false
            return
        }
        portCombo.enabled = true
        var oldText = portCombo.currentIndex >= 0 ? portCombo.currentText : ""
        portCombo.model = portStrings
        var idx = portCombo.find(oldText)
        if (idx !== -1) {
            portCombo.currentIndex = idx
        } else {
            portCombo.currentIndex = 0
        }
    }

    // 初始化
    Component.onCompleted: {
        refreshPortList()
        var baudIdx = baudCombo.find("57600")
        if (baudIdx !== -1) baudCombo.currentIndex = baudIdx
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: ScreenTools.defaultFontPixelWidth * 0.5
        spacing: ScreenTools.defaultFontPixelWidth * 0.5

        // 串口下拉框
        QGCComboBox {
            id: portCombo
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 11
            Layout.fillWidth: true
            enabled: !_isConnected
            sizeToContents: true
        }

        // 波特率下拉框
        QGCComboBox {
            id: baudCombo
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 11
            Layout.fillWidth: true
            enabled: !_isConnected
            model: QGroundControl.linkManager.serialBaudRates
            sizeToContents: true
        }

        // 连接/断开按钮
        Rectangle {
            id: connectButton
            Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 11
            Layout.fillWidth: true
            Layout.preferredHeight: baudCombo.height
            radius: 4
            color: {
                if (!_isConnected && portCombo.enabled && portCombo.currentIndex >= 0) {
                    return connectMouse.containsMouse ? "#45A049" : "#4CAF50"   // 绿色：可连接
                }
                if (_isConnected) {
                    return connectMouse.containsMouse ? "#D32F2F" : "#F44336"   // 红色：可断开
                }
                return "#BDBDBD"   // 灰色：无串口可用
            }

            QGCLabel {
                anchors.centerIn: parent
                text: _isConnected ? "断开" : "连接"
                color: "white"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
            }

            MouseArea {
                id: connectMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (_isConnected) {
                        // 断开连接
                        if (_currentConfig && _currentConfig.link) {
                            _currentConfig.link.disconnect()
                        }
                        _currentConfig = null
                        refreshPortList()
                    } else {
                        // 连接
                        if (portCombo.currentIndex < 0) return
                        var portIdx = portCombo.currentIndex
                        var portName = QGroundControl.linkManager.serialPorts[portIdx]
                        var baud = parseInt(baudCombo.currentText)
                        if (!portName || isNaN(baud)) return

                        var config = QGroundControl.linkManager.createConfiguration(
                            LinkConfiguration.TypeSerial, "SerialConnectBar"
                        )
                        config.portName = portName
                        config.baud = baud
                        QGroundControl.linkManager.createConnectedLink(config)
                        _currentConfig = config
                    }
                }
            }
        }
    }
}