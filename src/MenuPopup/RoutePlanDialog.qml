import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12
import QtPositioning 5.3

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.ScreenTools 1.0

Popup {
    id: routePlanDialog

    width: ScreenTools.defaultFontPixelWidth * 50
    height: ScreenTools.defaultFontPixelHeight * 30
    modal: false
    closePolicy: Popup.CloseOnEscape
    padding: 0

    property var mapControl: null
    property var planMasterController: null
    property var _missionController: planMasterController ? planMasterController.missionController : null
    property real _defaultSpeed: 10
    property string _routeName: ""
    property int _selectedRow: -1
    property bool _uploading: false
    property bool _pendingSend: false
    property string _statusText: ""
    // 表格内容总宽（各列宽度之和 + 分隔线）
    property real _tableContentWidth: ScreenTools.defaultFontPixelWidth * 78 + 7
    // 弹窗可调整宽度范围（用于侧边拖拽拉长/拉窄）
    // 最小宽度 = 初始宽度，左右缩小不能小于初始宽度
    property real _minWidth: ScreenTools.defaultFontPixelWidth * 50
    property real _maxWidth: ScreenTools.defaultFontPixelWidth * 90

    // 弹窗可调整高度范围（用于上下边及四角拖拽缩放）
    property real _minHeight: ScreenTools.defaultFontPixelHeight * 12
    property real _maxHeight: ScreenTools.defaultFontPixelHeight * 30




    onOpened: {
        x = (parent.width - width) / 2
        y = (parent.height - height) / 2
    }

    ListModel {
        id: waypointModel
    }

    function _calcDistance(coord1, coord2) {
        var R = 6371000
        var dLat = (coord2.latitude - coord1.latitude) * Math.PI / 180
        var dLon = (coord2.longitude - coord1.longitude) * Math.PI / 180
        var lat1 = coord1.latitude * Math.PI / 180
        var lat2 = coord2.latitude * Math.PI / 180
        var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2)
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
        return R * c
    }

    function _syncMap() {
        if (!mapControl) return
        var wps = []
        for (var i = 0; i < waypointModel.count; i++) {
            wps.push(waypointModel.get(i))
        }
        mapControl.syncRouteFromModel(wps)
    }

    function addRow() {
        var lastLon = 116.0
        var lastLat = 39.0
        if (waypointModel.count > 0) {
            var last = waypointModel.get(waypointModel.count - 1)
            lastLon = last.lon + 0.01
            lastLat = last.lat + 0.01
        }
        waypointModel.append({
            index: waypointModel.count + 1,
            lon: lastLon,
            lat: lastLat,
            alt: 100,
            speed: _defaultSpeed,
            hold: 0,
            yaw: 0
        })
        _syncMap()
    }

    function addCoordinate(lat, lon) {
        waypointModel.append({
            index: waypointModel.count + 1,
            lon: lon,
            lat: lat,
            alt: 100,
            speed: _defaultSpeed,
            hold: 0,
            yaw: 0
        })
        _syncMap()
    }

    function deleteRow() {
        if (_selectedRow >= 0 && _selectedRow < waypointModel.count) {
            waypointModel.remove(_selectedRow)
            _selectedRow = -1
            for (var i = 0; i < waypointModel.count; i++) {
                waypointModel.setProperty(i, "index", i + 1)
            }
            _syncMap()
        }
    }

    function clearAll() {
        waypointModel.clear()
        _selectedRow = -1
        if (mapControl) {
            mapControl.clearRouteWaypoints()
        }
    }

    function generateRoute() {
        if (waypointModel.count < 2) return
        if (mapControl) {
            mapControl.fitRouteToView()
        }
        routePlanDialog.close()
    }

    // 在 SimpleMissionItem 的 textFieldFacts/nanFacts 中查找指定名称的 Fact 并设置值
    function _setFactValue(item, factList, factName, value) {
        if (!item || !factList) return
        for (var i = 0; i < factList.count; i++) {
            var fact = factList.get(i)
            if (fact.name === factName) {
                fact.rawValue = value
                return
            }
        }
    }

    // 在 SimpleMissionItem 的 textFieldFacts/nanFacts 中查找指定名称的 Fact 并返回值
    function _getFactValue(item, factList, factName) {
        if (!item || !factList) return 0
        for (var i = 0; i < factList.count; i++) {
            var fact = factList.get(i)
            if (fact.name === factName) {
                return fact.rawValue
            }
        }
        return 0
    }

    // 把表格中的航点数据写入 MissionController
    function _buildMissionFromTable() {
        if (!_missionController) return
        planMasterController.removeAll()
        for (var i = 0; i < waypointModel.count; i++) {

            var wp = waypointModel.get(i)
            var coord = QtPositioning.coordinate(wp.lat, wp.lon)
            var item = _missionController.insertSimpleMissionItem(coord, -1, false)
            if (!item) continue
            // 设置高度
            item.altitude.rawValue = wp.alt
            // 设置速度
            item.speedSection.specifyFlightSpeed = true
            item.speedSection.flightSpeed.rawValue = wp.speed

            // 设置停留时间 (param1 = Hold)
            _setFactValue(item, item.textFieldFacts, "Hold", wp.hold)
            // 设置偏航角 (param4 = Yaw)
            _setFactValue(item, item.nanFacts, "Yaw", wp.yaw)
        }
    }

    // 从 MissionController 读取航点数据回填到表格
    function _fillTableFromMission() {
        console.log("RoutePlanDialog _fillTableFromMission called")
        if (!_missionController) {
            console.log("RoutePlanDialog _fillTableFromMission: _missionController is null")
            return
        }
        waypointModel.clear()
        var items = _missionController.visualItems
        console.log("RoutePlanDialog _fillTableFromMission: visualItems count =", items ? items.count : "null")
        if (!items) return
        for (var i = 0; i < items.count; i++) {
            var item = items.get(i)
            console.log("RoutePlanDialog _fillTableFromMission: item", i, "isSimpleItem =", item.isSimpleItem, "isTakeoffItem =", item.isTakeoffItem, "command =", item.command, "coordinate valid =", item.coordinate ? item.coordinate.isValid : "null")
            if (!item.isSimpleItem) {
                console.log("RoutePlanDialog _fillTableFromMission: item", i, "not simple, skipping")
                continue
            }
            var coord = item.coordinate
            if (!coord.isValid) {
                console.log("RoutePlanDialog _fillTableFromMission: item", i, "coordinate invalid, skipping")
                continue
            }

            var speed = 0
            if (item.speedSection && item.speedSection.specifyFlightSpeed) {
                speed = item.speedSection.flightSpeed.rawValue
            }
            var hold = _getFactValue(item, item.textFieldFacts, "Hold")
            var yaw = _getFactValue(item, item.nanFacts, "Yaw")
            waypointModel.append({
                index: waypointModel.count + 1,
                lon: coord.longitude,
                lat: coord.latitude,
                alt: item.altitude.rawValue,

                speed: speed,
                hold: hold,
                yaw: yaw
            })
        }
        console.log("RoutePlanDialog _fillTableFromMission: waypointModel count =", waypointModel.count)
        _selectedRow = -1
        _syncMap()
    }


    // 上传航线：先清空飞控现有航线，等 removeAll 完成后再上传
    function uploadRoute() {
        if (!planMasterController) return
        if (waypointModel.count < 1) return
        _buildMissionFromTable()
        _uploading = true
        _pendingSend = true
        _statusText = "正在清空飞控航线..."
        // 只启动 removeAll，等 removeAll 完成（syncInProgress 变为 false）后再 sendToVehicle
        planMasterController.removeAllFromVehicle()
    }


    // 下载航线：从飞控下载并回填表格
    function downloadRoute() {
        if (!planMasterController) return
        planMasterController.loadFromVehicle()
    }

    // 导入航线：从文件加载并回填表格
    function importRoute() {
        if (!planMasterController) return
        importFileDialog.openForLoad()
    }

    // 导出航线：保存到文件
    function exportRoute() {
        if (!planMasterController) return
        if (waypointModel.count < 1) return
        _buildMissionFromTable()
        exportFileDialog.openForSave()
    }

    // 导入文件选择对话框
    QGCFileDialog {
        id: importFileDialog
        title: "选择航线文件"
        folder: ""
        selectExisting: true
        nameFilters: planMasterController ? planMasterController.loadNameFilters : ["*.plan"]
        onAcceptedForLoad: {
            if (planMasterController) {
                planMasterController.loadFromFile(file)
            }
        }
    }

    // 导出文件保存对话框
    QGCFileDialog {
        id: exportFileDialog
        title: "保存航线文件"
        folder: ""
        selectExisting: false
        nameFilters: planMasterController ? planMasterController.saveNameFilters : ["*.plan"]
        onAcceptedForSave: {
            if (planMasterController) {
                planMasterController.saveToFile(file)
            }
        }
    }

    // 监听上传/下载/导入完成
    Connections {
        target: planMasterController
        onSyncInProgressChanged: {
            if (!planMasterController.syncInProgress) {
                if (_pendingSend) {
                    // removeAll 完成，现在真正发送航线
                    _pendingSend = false
                    _statusText = "正在上传航线..."
                    planMasterController.sendToVehicle()
                } else if (_uploading) {
                    // sendToVehicle 完成，上传成功
                    _uploading = false
                    _statusText = "航线上传成功"
                }
            }
        }
    }

    // 下载/导入完成后，_visualItems 更新完成时触发回填表格
    // 注意：syncInProgress 变为 false 时 _visualItems 可能还未更新，
    // 所以必须监听 newItemsFromVehicle 信号（在 _visualItems 更新完成后触发）
    Connections {
        target: _missionController
        onNewItemsFromVehicle: {
            console.log("RoutePlanDialog onNewItemsFromVehicle fired, pendingSend =", _pendingSend, "uploading =", _uploading)
            // 上传时跳过回填，避免覆盖表格
            if (!_pendingSend && !_uploading) {
                _fillTableFromMission()
                _statusText = ""
            }
        }
        onVisualItemsChanged: {
            console.log("RoutePlanDialog onVisualItemsChanged fired, pendingSend =", _pendingSend, "uploading =", _uploading)
            // 上传时跳过回填，避免覆盖表格
            if (!_pendingSend && !_uploading) {
                _fillTableFromMission()
                _statusText = ""
            }
        }
    }




    background: Rectangle {
        color: QGroundControl.globalPalette ? QGroundControl.globalPalette.window : "#491717"
        radius: 6
        border.color: Qt.rgba(0, 0, 0, 0.2)
        border.width: 1
    }

    contentItem: Item {
        ColumnLayout {
            anchors.fill: parent
            spacing: 0


        // 标题栏 (始终显示) - 支持拖拽
        Rectangle {
            id: titleBar
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
            color: "#1976D2"
            radius: 6

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height - 6
                color: "#1976D2"
            }

            QGCLabel {
                anchors.centerIn: parent
                text: "航线规划"
                color: "white"
                font.bold: true
                font.family: "Microsoft YaHei"
                font.pixelSize: ScreenTools.defaultFontPixelSize * 1.1
            }

            // 拖拽区域 - 按住标题栏可拖动整个对话框
            MouseArea {
                id: dragArea
                anchors.fill: parent
                cursorShape: Qt.OpenHandCursor
                property real startX: 0
                property real startY: 0
                onPressed: {
                    startX = mouse.x
                    startY = mouse.y
                    cursorShape = Qt.ClosedHandCursor
                }
                onReleased: cursorShape = Qt.OpenHandCursor
                onPositionChanged: {
                    routePlanDialog.x += mouse.x - startX
                    routePlanDialog.y += mouse.y - startY
                }
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
                    text: "X"
                    color: "white"
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: routePlanDialog.close()
                }
            }
        }

        // 内容区域
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: ScreenTools.defaultFontPixelHeight * 0.5
            Layout.bottomMargin: ScreenTools.defaultFontPixelHeight * 0.5
            spacing: ScreenTools.defaultFontPixelHeight * 0.4

            // 航线名称
            RowLayout {        // 水平布局容器
                Layout.fillWidth: true              // 填充父容器宽度
                Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2   // 左外边距
                Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.2  // 右外边距
                spacing: ScreenTools.defaultFontPixelWidth * 2         // 间距
                QGCLabel {
                    text: "航线名称: "
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.9
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: ScreenTools.defaultFontPixelHeight * 1.3
                    border.color: "#C0C0C0"
                    border.width: 1
                    radius: 3
                    TextInput {
                        id: routeNameInput
                        anchors.fill: parent
                        anchors.margins: 3
                        font.pixelSize: ScreenTools.defaultFontPixelSize * 0.9
                        clip: true
                        onTextChanged: _routeName = text
                    }
                }
            }

            // 功能按钮
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.2
                spacing: ScreenTools.defaultFontPixelWidth * 0.6

                QGCButton {
                    text: "下载航线"
                    Layout.fillWidth: true
                    height: ScreenTools.defaultFontPixelHeight * 1.3
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                    onClicked: downloadRoute()
                }
                QGCButton {
                    text: "上传航线"
                    Layout.fillWidth: true
                    height: ScreenTools.defaultFontPixelHeight * 1.3
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                    onClicked: uploadRoute()
                }
                QGCButton {
                    text: "导入航线"
                    Layout.fillWidth: true
                    height: ScreenTools.defaultFontPixelHeight * 1.3
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                    onClicked: importRoute()
                }
                QGCButton {
                    text: "导出航线"
                    Layout.fillWidth: true
                    height: ScreenTools.defaultFontPixelHeight * 1.3
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                    onClicked: exportRoute()
                }
            }

            // 状态提示
            QGCLabel {
                Layout.fillWidth: true
                Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.2
                text: _statusText
                visible: _statusText !== ""
                color: _statusText === "航线上传成功" ? "#2E7D32" : "#1976D2"
                font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                font.bold: true
                horizontalAlignment: Text.AlignLeft
            }

            // 表头

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.2
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.3
                color: "#E8E8E8"
                clip: true

                Flickable {
                    id: headerFlickable
                    anchors.fill: parent
                    contentWidth: _tableContentWidth
                    contentHeight: parent.height
                    interactive: false
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    // 表头与数据列表水平滚动同步
                    contentX: dataFlickable.contentX

                    RowLayout {
                        width: _tableContentWidth
                        height: parent.height
                        anchors.leftMargin: 3
                        anchors.rightMargin: 3
                        spacing: 1

                    QGCLabel {
                        text: "编号"
                        Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 4
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                        font.bold: true
                        color: "black"
                    }
                    Rectangle { width: 1; Layout.fillHeight: true; color: "#C0C0C0" }
                    QGCLabel {
                        text: "经度"
                        Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                        font.bold: true
                        color: "black"
                    }
                    Rectangle { width: 1; Layout.fillHeight: true; color: "#C0C0C0" }
                    QGCLabel {
                        text: "纬度"
                        Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                        font.bold: true
                        color: "black"
                    }
                    Rectangle { width: 1; Layout.fillHeight: true; color: "#C0C0C0" }
                    QGCLabel {
                        text: "高度(m)"
                        Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                        font.bold: true
                        color: "black"
                    }
                    Rectangle { width: 1; Layout.fillHeight: true; color: "#C0C0C0" }
                    QGCLabel {
                        text: "速度(m/s)"
                        Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 14
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                        font.bold: true
                        color: "black"
                    }
                    Rectangle { width: 1; Layout.fillHeight: true; color: "#C0C0C0" }
                    QGCLabel {
                        text: "停留时间(s)"
                        Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                        font.bold: true
                        color: "black"
                    }
                    Rectangle { width: 1; Layout.fillHeight: true; color: "#C0C0C0" }
                    QGCLabel {
                        text: "偏航角(°)"
                        Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: ScreenTools.defaultFontPixelSize * 0.8
                        font.bold: true
                        color: "black"
                    }
                    }
                }
            }

            // 数据列表
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.2
                border.color: "#C0C0C0"
                border.width: 1
                color: "white"
                clip: true

                Flickable {
                    id: dataFlickable
                    anchors.fill: parent
                    anchors.margins: 1
                    contentWidth: _tableContentWidth
                    contentHeight: parent.height
                    interactive: false
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true

                    ListView {
                        id: waypointListView
                        width: _tableContentWidth
                        height: parent.height
                        clip: true
                        model: waypointModel
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: Rectangle {
                            width: _tableContentWidth
                            height: ScreenTools.defaultFontPixelHeight * 1.5
                        color: index === _selectedRow ? "#D0E4F7" : (index % 2 === 0 ? "#FAFAFA" : "white")

                        MouseArea {
                            anchors.fill: parent
                            onClicked: _selectedRow = index
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 1
                            spacing: 1

                            QGCLabel {
                                text: model.index
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 4
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                                color: "black"
                            }
                            Rectangle { width: 1; Layout.fillHeight: true; color: "#E0E0E0" }

                            Rectangle {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                                Layout.fillHeight: true
                                color: "transparent"
                                TextInput {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                                    color: "black"
                                    text: lon.toFixed(6)
                                    validator: DoubleValidator { bottom: -180; top: 180; decimals: 6 }
                                    onEditingFinished: waypointModel.setProperty(index, "lon", parseFloat(text) || lon)
                                }
                            }
                            Rectangle { width: 1; Layout.fillHeight: true; color: "#E0E0E0" }

                            Rectangle {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                                Layout.fillHeight: true
                                color: "transparent"
                                TextInput {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                                    color: "black"
                                    text: lat.toFixed(6)
                                    validator: DoubleValidator { bottom: -90; top: 90; decimals: 6 }
                                    onEditingFinished: waypointModel.setProperty(index, "lat", parseFloat(text) || lat)
                                }
                            }
                            Rectangle { width: 1; Layout.fillHeight: true; color: "#E0E0E0" }

                            Rectangle {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                                Layout.fillHeight: true
                                color: "transparent"
                                TextInput {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                                    color: "black"
                                    text: alt.toFixed(0)
                                    validator: DoubleValidator { bottom: 0; top: 10000; decimals: 0 }
                                    onEditingFinished: waypointModel.setProperty(index, "alt", parseFloat(text) || alt)
                                }
                            }
                            Rectangle { width: 1; Layout.fillHeight: true; color: "#E0E0E0" }

                            Rectangle {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 14
                                Layout.fillHeight: true
                                color: "transparent"
                                TextInput {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                                    color: "black"
                                    text: speed.toFixed(1)
                                    validator: DoubleValidator { bottom: 0; top: 100; decimals: 1 }
                                    onEditingFinished: waypointModel.setProperty(index, "speed", parseFloat(text) || speed)
                                }
                            }
                            Rectangle { width: 1; Layout.fillHeight: true; color: "#E0E0E0" }

                            Rectangle {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                                Layout.fillHeight: true
                                color: "transparent"
                                TextInput {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                                    color: "black"
                                    text: hold.toFixed(0)
                                    validator: DoubleValidator { bottom: 0; top: 3600; decimals: 0 }
                                    onEditingFinished: waypointModel.setProperty(index, "hold", parseFloat(text) || hold)
                                }
                            }
                            Rectangle { width: 1; Layout.fillHeight: true; color: "#E0E0E0" }

                            Rectangle {
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                                Layout.fillHeight: true
                                color: "transparent"
                                TextInput {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                                    color: "black"
                                    text: yaw.toFixed(1)
                                    validator: DoubleValidator { bottom: -180; top: 180; decimals: 1 }
                                    onEditingFinished: waypointModel.setProperty(index, "yaw", parseFloat(text) || yaw)
                                }
                            }
                        }
                    }
                }
            }
            }

            // 水平滚动条
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.2
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.8
                color: "#D0D0D0"
                radius: 2
                visible: dataFlickable.contentWidth > dataFlickable.width

                // 滑块
                Rectangle {
                    id: hScrollThumb
                    width: Math.max(ScreenTools.defaultFontPixelWidth * 3, dataFlickable.width / dataFlickable.contentWidth * parent.width)
                    height: parent.height
                    radius: 2
                    color: hScrollMouse.containsMouse ? "#1976D2" : "#5A9BD5"
                    // 限制滑块在轨道范围内
                    x: Math.max(0, Math.min(parent.width - width,
                        dataFlickable.contentX / (dataFlickable.contentWidth - dataFlickable.width) * (parent.width - width)))

                    MouseArea {
                        id: hScrollMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        property real dragStartX: 0
                        property real contentStartX: 0
                        onPressed: {
                            dragStartX = mouse.x
                            contentStartX = dataFlickable.contentX
                        }
                        onPositionChanged: {
                            if (pressed) {
                                var trackWidth = hScrollThumb.parent.width - hScrollThumb.width
                                var maxContentX = dataFlickable.contentWidth - dataFlickable.width
                                var delta = mouse.x - dragStartX
                                // 限制 contentX 在 [0, maxContentX] 范围内
                                dataFlickable.contentX = Math.max(0, Math.min(maxContentX, contentStartX + delta / trackWidth * maxContentX))
                            }
                        }
                    }
                }
            }

            // 底部操作栏
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: ScreenTools.defaultFontPixelWidth * 1.2
                Layout.rightMargin: ScreenTools.defaultFontPixelWidth * 1.2
                spacing: ScreenTools.defaultFontPixelWidth * 0.5

                QGCButton {
                    text: "添加行"
                    height: ScreenTools.defaultFontPixelHeight * 1.3
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 7
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                    onClicked: addRow()
                }
                QGCButton {
                    text: "删除选中行"
                    height: ScreenTools.defaultFontPixelHeight * 1.3
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 10
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                    enabled: _selectedRow >= 0
                    onClicked: deleteRow()
                }
                QGCButton {
                    text: "清空全部"
                    height: ScreenTools.defaultFontPixelHeight * 1.3
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                    enabled: waypointModel.count > 0
                    onClicked: clearAll()
                }

                Item { Layout.fillWidth: true }

                QGCButton {
                    text: "取消"
                    height: ScreenTools.defaultFontPixelHeight * 1.3
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 6
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                    onClicked: routePlanDialog.close()
                }
                QGCButton {
                    text: "生成航线"
                    height: ScreenTools.defaultFontPixelHeight * 1.3
                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 8
                    font.pixelSize: ScreenTools.defaultFontPixelSize * 0.85
                    enabled: waypointModel.count >= 2
                    onClicked: generateRoute()
                }
            }
        }
    }

    // ==================== 弹窗缩放拖拽手柄 ====================
    // 四个边的手柄：鼠标放在边上左击拖拽可调整单方向尺寸
    // 四个角的手柄：鼠标放在角上左击拖拽可同时调整宽高

    // ---- 右边手柄：调整宽度 ----
    MouseArea {
        id: resizeRight
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: ScreenTools.defaultFontPixelWidth * 0.8
        cursorShape: Qt.SizeHorCursor
        hoverEnabled: true
        property real startGlobalX: 0
        property real startWidth: 0
        onPressed: {
            startGlobalX = resizeRight.mapToGlobal(mouse.x, mouse.y).x
            startWidth = routePlanDialog.width
        }
        onPositionChanged: {
            if (pressed) {
                var delta = resizeRight.mapToGlobal(mouse.x, mouse.y).x - startGlobalX
                routePlanDialog.width = Math.max(_minWidth, Math.min(_maxWidth, startWidth + delta))
            }
        }
    }

    // ---- 左边手柄：调整宽度（左边缘移动） ----
    MouseArea {
        id: resizeLeft
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: ScreenTools.defaultFontPixelWidth * 0.8
        cursorShape: Qt.SizeHorCursor
        hoverEnabled: true
        property real startGlobalX: 0
        property real startWidth: 0
        property real startX: 0
        onPressed: {
            startGlobalX = resizeLeft.mapToGlobal(mouse.x, mouse.y).x
            startWidth = routePlanDialog.width
            startX = routePlanDialog.x
        }
        onPositionChanged: {
            if (pressed) {
                var delta = resizeLeft.mapToGlobal(mouse.x, mouse.y).x - startGlobalX
                var newWidth = Math.max(_minWidth, Math.min(_maxWidth, startWidth - delta))
                routePlanDialog.width = newWidth
                routePlanDialog.x = startX + (startWidth - newWidth)
            }
        }
    }

    // ---- 下边手柄：调整高度 ----
    MouseArea {
        id: resizeBottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: ScreenTools.defaultFontPixelHeight * 0.5
        cursorShape: Qt.SizeVerCursor
        hoverEnabled: true
        property real startGlobalY: 0
        property real startHeight: 0
        onPressed: {
            startGlobalY = resizeBottom.mapToGlobal(mouse.x, mouse.y).y
            startHeight = routePlanDialog.height
        }
        onPositionChanged: {
            if (pressed) {
                var delta = resizeBottom.mapToGlobal(mouse.x, mouse.y).y - startGlobalY
                routePlanDialog.height = Math.max(_minHeight, Math.min(_maxHeight, startHeight + delta))
            }
        }
    }

    // ---- 上边手柄：调整高度（上边缘移动） ----
    MouseArea {
        id: resizeTop
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: ScreenTools.defaultFontPixelHeight * 0.5
        cursorShape: Qt.SizeVerCursor
        hoverEnabled: true
        property real startGlobalY: 0
        property real startHeight: 0
        property real startY: 0
        onPressed: {
            startGlobalY = resizeTop.mapToGlobal(mouse.x, mouse.y).y
            startHeight = routePlanDialog.height
            startY = routePlanDialog.y
        }
        onPositionChanged: {
            if (pressed) {
                var delta = resizeTop.mapToGlobal(mouse.x, mouse.y).y - startGlobalY
                var newHeight = Math.max(_minHeight, Math.min(_maxHeight, startHeight - delta))
                routePlanDialog.height = newHeight
                routePlanDialog.y = startY + (startHeight - newHeight)
            }
        }
    }

    // ---- 右下角手柄：同时调整宽高 ----
    MouseArea {
        id: resizeBottomRight
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: ScreenTools.defaultFontPixelWidth * 1.2
        height: ScreenTools.defaultFontPixelHeight * 0.8
        cursorShape: Qt.SizeFDiagCursor
        hoverEnabled: true
        z: 10
        property real startGlobalX: 0
        property real startGlobalY: 0
        property real startWidth: 0
        property real startHeight: 0
        onPressed: {
            var g = resizeBottomRight.mapToGlobal(mouse.x, mouse.y)
            startGlobalX = g.x
            startGlobalY = g.y
            startWidth = routePlanDialog.width
            startHeight = routePlanDialog.height
        }
        onPositionChanged: {
            if (pressed) {
                var g = resizeBottomRight.mapToGlobal(mouse.x, mouse.y)
                routePlanDialog.width = Math.max(_minWidth, Math.min(_maxWidth, startWidth + (g.x - startGlobalX)))
                routePlanDialog.height = Math.max(_minHeight, Math.min(_maxHeight, startHeight + (g.y - startGlobalY)))
            }
        }
    }

    // ---- 左下角手柄：同时调整宽高（左边缘、下边缘移动） ----
    MouseArea {
        id: resizeBottomLeft
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: ScreenTools.defaultFontPixelWidth * 1.2
        height: ScreenTools.defaultFontPixelHeight * 0.8
        cursorShape: Qt.SizeBDiagCursor
        hoverEnabled: true
        z: 10
        property real startGlobalX: 0
        property real startGlobalY: 0
        property real startWidth: 0
        property real startHeight: 0
        property real startX: 0
        onPressed: {
            var g = resizeBottomLeft.mapToGlobal(mouse.x, mouse.y)
            startGlobalX = g.x
            startGlobalY = g.y
            startWidth = routePlanDialog.width
            startHeight = routePlanDialog.height
            startX = routePlanDialog.x
        }
        onPositionChanged: {
            if (pressed) {
                var g = resizeBottomLeft.mapToGlobal(mouse.x, mouse.y)
                var newWidth = Math.max(_minWidth, Math.min(_maxWidth, startWidth - (g.x - startGlobalX)))
                routePlanDialog.width = newWidth
                routePlanDialog.x = startX + (startWidth - newWidth)
                routePlanDialog.height = Math.max(_minHeight, Math.min(_maxHeight, startHeight + (g.y - startGlobalY)))
            }
        }
    }

    // ---- 右上角手柄：同时调整宽高（上边缘、右边缘移动） ----
    MouseArea {
        id: resizeTopRight
        anchors.right: parent.right
        anchors.top: parent.top
        width: ScreenTools.defaultFontPixelWidth * 1.2
        height: ScreenTools.defaultFontPixelHeight * 0.8
        cursorShape: Qt.SizeBDiagCursor
        hoverEnabled: true
        z: 10
        property real startGlobalX: 0
        property real startGlobalY: 0
        property real startWidth: 0
        property real startHeight: 0
        property real startY: 0
        onPressed: {
            var g = resizeTopRight.mapToGlobal(mouse.x, mouse.y)
            startGlobalX = g.x
            startGlobalY = g.y
            startWidth = routePlanDialog.width
            startHeight = routePlanDialog.height
            startY = routePlanDialog.y
        }
        onPositionChanged: {
            if (pressed) {
                var g = resizeTopRight.mapToGlobal(mouse.x, mouse.y)
                routePlanDialog.width = Math.max(_minWidth, Math.min(_maxWidth, startWidth + (g.x - startGlobalX)))
                var newHeight = Math.max(_minHeight, Math.min(_maxHeight, startHeight - (g.y - startGlobalY)))
                routePlanDialog.height = newHeight
                routePlanDialog.y = startY + (startHeight - newHeight)
            }
        }
    }

    // ---- 左上角手柄：同时调整宽高（左边缘、上边缘移动） ----
    MouseArea {
        id: resizeTopLeft
        anchors.left: parent.left
        anchors.top: parent.top
        width: ScreenTools.defaultFontPixelWidth * 1.2
        height: ScreenTools.defaultFontPixelHeight * 0.8
        cursorShape: Qt.SizeFDiagCursor
        hoverEnabled: true
        z: 10
        property real startGlobalX: 0
        property real startGlobalY: 0
        property real startWidth: 0
        property real startHeight: 0
        property real startX: 0
        property real startY: 0
        onPressed: {
            var g = resizeTopLeft.mapToGlobal(mouse.x, mouse.y)
            startGlobalX = g.x
            startGlobalY = g.y
            startWidth = routePlanDialog.width
            startHeight = routePlanDialog.height
            startX = routePlanDialog.x
            startY = routePlanDialog.y
        }
        onPositionChanged: {
            if (pressed) {
                var g = resizeTopLeft.mapToGlobal(mouse.x, mouse.y)
                var newWidth = Math.max(_minWidth, Math.min(_maxWidth, startWidth - (g.x - startGlobalX)))
                routePlanDialog.width = newWidth
                routePlanDialog.x = startX + (startWidth - newWidth)
                var newHeight = Math.max(_minHeight, Math.min(_maxHeight, startHeight - (g.y - startGlobalY)))
                routePlanDialog.height = newHeight
                routePlanDialog.y = startY + (startHeight - newHeight)
            }
        }
    }
    }
}




