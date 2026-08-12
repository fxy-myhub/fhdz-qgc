import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12
import QtPositioning 5.3

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.ScreenTools 1.0

Popup {
    id: mapConfigDialog

    width: ScreenTools.defaultFontPixelWidth * 30
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    property var mapControl: null
    property var rootItem: null

    property real _inputLon: 0.0
    property real _inputLat: 0.0
    property bool _inputValid: false

    function _validateInput() {
        _inputValid = (lonField.acceptableInput && latField.acceptableInput)
    }

    background: Rectangle {
        color: QGroundControl.globalPalette ? QGroundControl.globalPalette.window : "#FFFFFF"
        radius: 6
        border.color: Qt.rgba(0, 0, 0, 0.2)
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        // ---- 标题栏（可拖拽） ----
        Rectangle {
            id: titleBar
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
            color: "#1976D2"
            radius: 6

            // 只保留顶部圆角
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height - 6
                color: "#1976D2"
            }

            QGCLabel {
                anchors.centerIn: parent
                text: "二维地图配置"
                color: "white"
                font.bold: true
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize * 1.1
            }

            // 关闭按钮
            Rectangle {
                id: closeBtn
                anchors.right: parent.right
                anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 0.8
                anchors.verticalCenter: parent.verticalCenter
                width: ScreenTools.defaultFontPixelHeight * 1.1
                height: ScreenTools.defaultFontPixelHeight * 1.1
                radius: width / 2
                color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : "transparent"

                QGCLabel {
                    anchors.centerIn: parent
                    text: "✕"
                    color: "white"
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mapConfigDialog.close()
                }
            }

            // 拖拽区域
            MouseArea {
                anchors.fill: parent
                anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 3
                cursorShape: Qt.OpenHandCursor
                property real _startX: 0
                property real _startY: 0
                onPressed: {
                    _startX = mouse.x
                    _startY = mouse.y
                }
                onPositionChanged: {
                    mapConfigDialog.x += mouse.x - _startX
                    mapConfigDialog.y += mouse.y - _startY
                }
            }
        }

        // ---- 内容区 ----
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.5
            color: "transparent"
        }

        // 地图切换
        QGCLabel {
            Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.5
            text: "地图切换"
            font.pointSize: ScreenTools.mediumFontPointSize
            font.bold: true
            font.family: "Microsoft YaHei"
            color: "white"
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.2
            color: "transparent"
        }

        QGCComboBox {
            id: mapCombo
            Layout.fillWidth: true
            Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.5
            Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.5
            sizeToContents: true
            model: {
                if (mapControl) {
                    var names = []
                    for (var i = 0; i < mapControl.supportedMapTypes.length; i++) {
                        names.push(mapControl.supportedMapTypes[i].name)
                    }
                    return names
                }
                return []
            }
            popup.parent: Overlay.overlay
            popup.onOpened: {
                var globalPos = mapCombo.mapToGlobal(0, mapCombo.height)
                var overlayPos = Overlay.overlay.mapFromGlobal(globalPos.x, globalPos.y)
                popup.x = overlayPos.x
                popup.y = overlayPos.y
                popup.z = mapConfigDialog.z + 1
            }
            onActivated: {
                if (mapControl && index >= 0 && index < mapControl.supportedMapTypes.length) {
                    mapControl.activeMapType = mapControl.supportedMapTypes[index]
                    var name = textAt(index)
                    var spaceIdx = name.indexOf(" ")
                    if (spaceIdx > 0) {
                        QGroundControl.settingsManager.flightMapSettings.mapProvider.value = name.substring(0, spaceIdx)
                        QGroundControl.settingsManager.flightMapSettings.mapType.value = name.substring(spaceIdx + 1)
                    }
                }
            }
            Component.onCompleted: {
                if (mapControl && mapControl.activeMapType) {
                    var idx = mapCombo.find(mapControl.activeMapType.name)
                    if (idx >= 0) mapCombo.currentIndex = idx
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.5
            color: "transparent"
        }

        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(0, 0, 0, 0.08)
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.5
            color: "transparent"
        }

        // 定位功能
        QGCLabel {
            Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.5
            text: "定位功能"
            font.pointSize: ScreenTools.mediumFontPointSize
            font.bold: true
            font.family: "Microsoft YaHei"
            color: "white"
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.2
            color: "transparent"
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.5
            Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.5
            columns: 2
            columnSpacing: ScreenTools.defaultFontPixelWidth * 0.8
            rowSpacing: ScreenTools.defaultFontPixelHeight * 0.2

            QGCLabel {
                text: "经度:"
                font.family: "Microsoft YaHei"
                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 6
            }
            TextField {
                id: lonField
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.3
                placeholderText: "如: 116.397428"
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize
                validator: DoubleValidator { bottom: -180.0; top: 180.0; decimals: 10 }
                onTextChanged: {
                    _inputLon = parseFloat(text)
                    _validateInput()
                }
            }

            QGCLabel {
                text: "纬度:"
                font.family: "Microsoft YaHei"
                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 6
            }
            TextField {
                id: latField
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.3
                placeholderText: "如: 39.909204"
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize
                validator: DoubleValidator { bottom: -90.0; top: 90.0; decimals: 10 }
                onTextChanged: {
                    _inputLat = parseFloat(text)
                    _validateInput()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.5
            color: "transparent"
        }

        // 定位按钮
        Rectangle {
            id: locateBtn
            Layout.fillWidth: true
            Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.5
            Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.5
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
            radius: 4
            color: _inputValid ? (locateMouse.containsMouse ? "#1565C0" : "#1976D2") : "#BDBDBD"

            QGCLabel {
                anchors.centerIn: parent
                text: "定位到该坐标"
                color: "white"
                font.bold: true
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize
            }

            MouseArea {
                id: locateMouse
                anchors.fill: parent
                enabled: _inputValid
                hoverEnabled: true
                cursorShape: _inputValid ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (mapControl && rootItem) {
                        var coord = QtPositioning.coordinate(_inputLat, _inputLon)
                        mapControl.center = coord
                        mapControl.zoomLevel = 16
                        rootItem._locateMarkerCoord = coord
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.6
            color: "transparent"
        }
    }
}