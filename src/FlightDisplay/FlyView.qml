/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.12
import QtQuick.Controls         2.4
import QtQuick.Dialogs          1.3
import QtQuick.Layouts          1.12

import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Airmap        1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.MenuComponents 1.0
import QGroundControl.MenuPopup     1.0

import "."

Item {
    id: _root

    // These should only be used by MainRootWindow
    property var planController:    _planController
    property var guidedController:  _guidedController

    PlanMasterController {
        id:                     _planController
        flyView:                true
        Component.onCompleted:  start()
    }

    property bool   _mainWindowIsMap:       mapControl.pipState.state === mapControl.pipState.fullState
    property bool   _isFullWindowItemDark:  _mainWindowIsMap ? mapControl.isSatelliteMap : true
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _missionController:     _planController.missionController
    property var    _geoFenceController:    _planController.geoFenceController
    property var    _rallyPointController:  _planController.rallyPointController
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property var    _guidedController:      guidedActionsController
    property var    _guidedActionList:      guidedActionList
    property var    _guidedAltSlider:       guidedAltSlider
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property var    _mapControl:            mapControl
    // 重点信息栏配置弹窗共享实例（供地图右键菜单和仪表盘下方容器通过 parent 访问）
    property alias  configMenuInstance:     configMenu

    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    function _calcCenterViewPort() {
        var newToolInset = Qt.rect(0, 0, width, height)
        toolstrip.adjustToolInset(newToolInset)
        if (QGroundControl.corePlugin.options.instrumentWidget) {
            flightDisplayViewWidgets.adjustToolInset(newToolInset)
        }
    }

    //工具内嵌区域（定义工具内嵌区域，用于计算地图视图的中心区域，避免被画中画覆盖）
    QGCToolInsets {
        id:                     _toolInsets
        leftEdgeBottomInset:    _pipOverlay.visible ? _pipOverlay.x + _pipOverlay.width : 0
        bottomEdgeLeftInset:    _pipOverlay.visible ? parent.height - _pipOverlay.y : 0
    }

    //显示飞行视图中的小部件
    FlyViewWidgetLayer {
        id:                     widgetLayer
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.left:           parent.left
        anchors.right:          guidedAltSlider.visible ? guidedAltSlider.left : parent.right
        z:                      _fullItemZorder + 1
        parentToolInsets:       _toolInsets
        mapControl:             _mapControl
        visible:                !QGroundControl.videoManager.fullScreen
    }
    //自定义覆盖层，用于显示自定义 UI 元素。
    FlyViewCustomLayer {
        id:                 customOverlay
        anchors.fill:       widgetLayer
        z:                  _fullItemZorder + 2
        parentToolInsets:   widgetLayer.totalToolInsets
        mapControl:         _mapControl
        visible:            !QGroundControl.videoManager.fullScreen
    }
    //管理引导模式下的动作逻辑
    GuidedActionsController {
        id:                 guidedActionsController
        missionController:  _missionController
        actionList:         _guidedActionList
        altitudeSlider:     _guidedAltSlider
    }

    /*GuidedActionConfirm {
        id:                         guidedActionConfirm
        anchors.margins:            _margins
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        z:                          QGroundControl.zOrderTopMost
        guidedController:           _guidedController
        altitudeSlider:             _guidedAltSlider
    }*/
    //显示引导模式下的可用动作列表（起飞、降落、悬停等）
    GuidedActionList {
        id:                         guidedActionList
        anchors.margins:            _margins
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        z:                          QGroundControl.zOrderTopMost
        guidedController:           _guidedController
    }

    //-- Altitude slider引导模式下调整目标高度的滑块
    GuidedAltitudeSlider {
        id:                 guidedAltSlider
        anchors.margins:    _toolsMargin
        anchors.right:      parent.right
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        z:                  QGroundControl.zOrderTopMost
        radius:             ScreenTools.defaultFontPixelWidth / 2
        width:              ScreenTools.defaultFontPixelWidth * 10
        color:              qgcPal.window
        visible:            false
    }

    //地图视图:飞行显示地图，显示无人机位置、轨迹、任务点等
    FlyViewMap {
        id:                     mapControl
        planMasterController:   _planController
        rightPanelWidth:        ScreenTools.defaultFontPixelHeight * 9
        pipMode:                !_mainWindowIsMap
        toolInsets:             customOverlay.totalToolInsets
        mapName:                "FlightDisplayView"
        allowPanGesture:        mainWindow.moveToolMode
        routePlanDialog:        routePlanDialog

        // 定位标记：在地图上显示图标
        MapQuickItem {
            id:                     locateMarker
            coordinate:             _root._locateMarkerCoord ? _root._locateMarkerCoord : QtPositioning.coordinate(0, 0)
            visible:                _root._locateMarkerCoord !== undefined
            anchorPoint.x:          locateMarkerImg.width / 2
            anchorPoint.y:          locateMarkerImg.height
            z:                      QGroundControl.zOrderTopMost
            sourceItem: Image {
                id:                 locateMarkerImg
                source:             "/qmlimages/定位.png"
                width:              ScreenTools.defaultFontPixelWidth * 5
                height:             ScreenTools.defaultFontPixelWidth * 5
                fillMode:           Image.PreserveAspectFit
            }
        }
    }

    // 定位标记坐标
    property var _locateMarkerCoord: undefined

    //----------------------------------------------------------------------
    // 鼠标悬停跟踪: 实时显示光标所在位置的经纬度
    // 数据流: MouseArea.onPositionChanged → toCoordinate() → 更新属性 → Text绑定刷新
    //----------------------------------------------------------------------
    property real   _hoverLatitude:  0.0        // 存储鼠标当前位置的纬度
    property real   _hoverLongitude: 0.0        // 存储鼠标当前位置的经度
    property bool   _hoverValid:     false      // 标记当前悬停坐标是否有效（鼠标在地图范围内）

    // 鼠标悬停检测区域，覆盖整个地图，无侵入式地追踪鼠标位置
    MouseArea {
        id:                     coordinateHoverArea
        anchors.fill:           mapControl          // 铺满整个地图控件
        hoverEnabled:           true                // 启用悬停检测
        acceptedButtons:        Qt.NoButton         // 不接收任何鼠标按键，让事件穿透到下层地图，保证正常交互
        z:                      5                   // 层级，在地图之上
        onPositionChanged: {
            // 将屏幕像素坐标转换为地理坐标（经纬度）
            var coord = mapControl.toCoordinate(Qt.point(mouse.x, mouse.y))
            if (coord.isValid) {
                // 坐标有效时更新存储，Text组件通过属性绑定自动刷新显示
                _hoverLatitude  = coord.latitude
                _hoverLongitude = coord.longitude
                _hoverValid     = true
            }
        }
    }

    // 经纬度文字显示: 固定在地图左下角，深红色加粗，保留6位小数
    Text {
        anchors.left:           mapControl.left
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * 1
        anchors.bottom:         mapControl.bottom
        anchors.bottomMargin:   ScreenTools.defaultFontPixelHeight * 0.5
        // 通过属性绑定自动更新: _hoverValid为true时显示经纬度，否则显示空字符串
        text:                   _hoverValid ? "经度 " + _hoverLongitude.toFixed(6) + "   纬度 " + _hoverLatitude.toFixed(6) : ""
        color:                  "red"            // 深红色
        font.pixelSize:         ScreenTools.defaultFontPixelHeight  
        font.bold:              true
        z:                      QGroundControl.zOrderTopMost + 1  // 最高层级，确保始终可见
    }

    // 串口连接栏: 地图右下角，选择串口和波特率，连接/断开飞控
    SerialConnectBar {
        id:                     serialConnectBar
        anchors.right:          mapControl.right
        anchors.rightMargin:    _toolsMargin
        anchors.bottom:         mapControl.bottom
        anchors.bottomMargin:   _toolsMargin
        visible:                !QGroundControl.videoManager.fullScreen
        z:                      QGroundControl.zOrderTopMost
    }
    
        // 命令按钮组: 地图底部中间，点火/熄火/开伞/盘旋/归航
    CommandButtonGroup {
        id:                     commandButtonGroup
        anchors.horizontalCenter: mapControl.horizontalCenter
        anchors.bottom:         mapControl.bottom
        anchors.bottomMargin:   _toolsMargin
        visible:                !QGroundControl.videoManager.fullScreen
        z:                      QGroundControl.zOrderTopMost
    }

    // 黄色刘海: 地图顶部正中间，紧贴地图顶端（快捷栏下方），用于发送/显示飞控当前信息
    YellowNotch {
        id:                     yellowNotch
        anchors.top:            mapControl.top
        anchors.topMargin:      0
        anchors.horizontalCenter: mapControl.horizontalCenter
        visible:                !QGroundControl.videoManager.fullScreen
        z:                      QGroundControl.zOrderTopMost
        // 后期将 infoText 绑定为飞控实时信息字符串
        // infoText:              _activeVehicle ? ... : "飞控信息"
    }



    //距离测量虚线:Canvas绘制
    Canvas {
        id:                     measureCanvas
        anchors.fill:           mapControl
        z:                      14
        visible:                mapControl._measureStartPoint !== undefined

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var startCoord = mapControl._measureStartPoint
            var endCoord = mapControl._measureEndPoint ? mapControl._measureEndPoint : mapControl._measureCurrentPoint
            if (!startCoord || !endCoord) return

            var sp = mapControl.fromCoordinate(startCoord)
            var ep = mapControl.fromCoordinate(endCoord)

            ctx.beginPath()
            ctx.strokeStyle = "#8B0000"
            ctx.lineWidth = 2
            ctx.setLineDash([6, 4])
            ctx.moveTo(sp.x, sp.y)
            ctx.lineTo(ep.x, ep.y)
            ctx.stroke()
        }
    }

    // 经纬度网格
    Canvas {
        id:                     gridCanvas
        anchors.fill:           mapControl
        z:                      5
        visible:                _showGrid

        Connections {
            target: mapControl
            onCenterChanged:    { if (_showGrid) gridCanvas.requestPaint() }
            onZoomLevelChanged: { if (_showGrid) gridCanvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            if (!_showGrid) return

            var nw = mapControl.toCoordinate(Qt.point(0, 0), false)
            var se = mapControl.toCoordinate(Qt.point(width, height), false)
            if (!nw.isValid || !se.isValid) return

            var latMin = Math.min(nw.latitude, se.latitude)
            var latMax = Math.max(nw.latitude, se.latitude)
            var lonMin = Math.min(nw.longitude, se.longitude)
            var lonMax = Math.max(nw.longitude, se.longitude)

            var spacing
            var zoom = mapControl.zoomLevel
            if (zoom >= 18) {
                spacing = 0.001
            } else if (zoom >= 15) {
                spacing = 0.01
            } else if (zoom >= 10) {
                spacing = 0.1
            } else if (zoom >= 5) {
                spacing = 1.0
            } else {
                spacing = 5.0
            }

            ctx.beginPath()
            ctx.strokeStyle = "rgba(255, 255, 255, 0.55)"
            ctx.lineWidth = 0.5

            var latStart = Math.floor(latMin / spacing) * spacing
            for (var lat = latStart; lat <= latMax; lat += spacing) {
                var leftPt = mapControl.fromCoordinate(QtPositioning.coordinate(lat, lonMin))
                var rightPt = mapControl.fromCoordinate(QtPositioning.coordinate(lat, lonMax))
                ctx.moveTo(leftPt.x, leftPt.y)
                ctx.lineTo(rightPt.x, rightPt.y)
            }

            var lonStart = Math.floor(lonMin / spacing) * spacing
            for (var lon = lonStart; lon <= lonMax; lon += spacing) {
                var topPt = mapControl.fromCoordinate(QtPositioning.coordinate(latMin, lon))
                var bottomPt = mapControl.fromCoordinate(QtPositioning.coordinate(latMax, lon))
                ctx.moveTo(topPt.x, topPt.y)
                ctx.lineTo(bottomPt.x, bottomPt.y)
            }

            ctx.stroke()
        }
    }

    //距离测量文本:显示在虚线右侧
    Text {
        id:                     measureDistanceText
        visible:                mapControl._measureStartPoint !== undefined
        color:                  "#FF0000"
        font.pixelSize:         ScreenTools.defaultFontPixelSize
        font.bold:              true
        z:                      QGroundControl.zOrderTopMost + 1
        text: {
            if (!mapControl._measureStartPoint) return ""
            var endPt = mapControl._measureEndPoint ? mapControl._measureEndPoint : mapControl._measureCurrentPoint
            if (!endPt) return ""
            var dist = mapControl._measureStartPoint.distanceTo(endPt)
            if (dist >= 1000) {
                return (dist / 1000).toFixed(2) + " km"
            } else {
                return dist.toFixed(2) + " m"
            }
        }
        function updatePosition() {
            if (!mapControl._measureStartPoint) return
            var endCoord = mapControl._measureEndPoint ? mapControl._measureEndPoint : mapControl._measureCurrentPoint
            if (!endCoord) return
            var sp = mapControl.fromCoordinate(mapControl._measureStartPoint)
            var ep = mapControl.fromCoordinate(endCoord)
            x = (sp.x + ep.x) / 2 + 12
            y = (sp.y + ep.y) / 2 - 12
        }
    }

    //距离测量区域:点击确定起点/终点,右键取消
    MouseArea {
        id:                     measureArea
        anchors.fill:           mapControl
        enabled:                mainWindow.measureToolMode
        cursorShape:            mainWindow.measureToolMode ? Qt.CrossCursor : Qt.ArrowCursor
        acceptedButtons:        Qt.LeftButton | Qt.RightButton
        z:                      15
        hoverEnabled:           mainWindow.measureToolMode

        onPressed: {
            if (mouse.button === Qt.RightButton) {
                mapControl._measureActive = false
                mapControl._measureStartPoint = undefined
                mapControl._measureEndPoint = undefined
                mapControl._measureCurrentPoint = undefined
                measureCanvas.requestPaint()
                return
            }
            var coord = mapControl.toCoordinate(Qt.point(mouse.x, mouse.y))
            if (!coord.isValid) return
            // 同步更新坐标显示
            _hoverLatitude = coord.latitude
            _hoverLongitude = coord.longitude
            _hoverValid = true

            if (!mapControl._measureActive) {
                mapControl._measureStartPoint = coord
                mapControl._measureCurrentPoint = coord
                mapControl._measureEndPoint = undefined
                mapControl._measureActive = true
            } else {
                mapControl._measureEndPoint = coord
                mapControl._measureCurrentPoint = undefined
                mapControl._measureActive = false
            }
            measureCanvas.requestPaint()
            measureDistanceText.updatePosition()
        }
        onPositionChanged: {
            var coord = mapControl.toCoordinate(Qt.point(mouse.x, mouse.y))
            if (coord.isValid) {
                // 同步更新坐标显示
                _hoverLatitude = coord.latitude
                _hoverLongitude = coord.longitude
                _hoverValid = true
            }
            if (mapControl._measureActive && coord.isValid) {
                mapControl._measureCurrentPoint = coord
                measureCanvas.requestPaint()
                measureDistanceText.updatePosition()
            }
        }
    }

    //地图缩放区域:点击地图缩放
    MouseArea {
        id:                     zoomClickArea
        anchors.fill:           mapControl   //让鼠标区域覆盖地图
        enabled:                mainWindow.zoomOnClickMode || mainWindow.zoomOutOnClickMode //缩放模式下才启用
        cursorShape:            (mainWindow.zoomOnClickMode || mainWindow.zoomOutOnClickMode) ? Qt.CrossCursor : Qt.ArrowCursor //缩放模式下显示十字光标
        z:                      10  //确保鼠标区域在地图之上
        //点击事件处理
        onClicked: {
            if (mainWindow.zoomOnClickMode) {
                //放大地图
                var coord = mapControl.toCoordinate(Qt.point(mouse.x, mouse.y))
                if (coord.isValid) {
                    mapControl.center = coord
                    mapControl.zoomLevel = Math.min(mapControl.zoomLevel + 1, mapControl.maxZoomLevel)
                }
            } else if (mainWindow.zoomOutOnClickMode) {
                //缩小地图
                var coord = mapControl.toCoordinate(Qt.point(mouse.x, mouse.y))
                if (coord.isValid) {
                    mapControl.center = coord
                    mapControl.zoomLevel = Math.max(mapControl.zoomLevel - 1, 2)
                }
            }
        }
    }
    //显示视频流（图传画面）
    FlyViewVideo {
        id: videoControl
    }

    QGCPipOverlay {
        id:                     _pipOverlay
        anchors.left:           parent.left
        anchors.bottom:         parent.bottom
        anchors.margins:        _toolsMargin
        item1IsFullSettingsKey: "MainFlyWindowIsMap"
        item1:                  mapControl
        item2:                  QGroundControl.videoManager.hasVideo ? videoControl : null
        fullZOrder:             _fullItemZorder
        pipZOrder:              _pipItemZorder
        show:                   !QGroundControl.videoManager.fullScreen &&
                                    (videoControl.pipState.state === videoControl.pipState.pipState || mapControl.pipState.state === mapControl.pipState.pipState)
    }
    // 二维地图配置弹窗
    MapConfigDialog {
        id: mapConfigDialog
        mapControl: mapControl
        rootItem: _root
        x: (_root.width - width) / 2
        y: (_root.height - height) / 2
        z: QGroundControl.zOrderTopMost + 10
    }

// 发动机配置弹窗
    EngineConfigDialog {
        id: engineConfigDialog
        rootItem: _root
        x: (_root.width - width) / 2
        y: (_root.height - height) / 2
        z: QGroundControl.zOrderTopMost + 10
    }

    // PWM通道配置弹窗
    PWMConfigDialog {
        id: pwmConfigDialog
        rootItem: _root
        x: (_root.width - width) / 2
        y: (_root.height - height) / 2
        z: QGroundControl.zOrderTopMost + 10
    }

    // 串口功能配置弹窗
    SerialConfigDialog {
        id: serialConfigDialog
        rootItem: _root
        x: (_root.width - width) / 2
        y: (_root.height - height) / 2
        z: QGroundControl.zOrderTopMost + 10
    }

    // 全部参数弹窗
    ParameterDialog {
        id: parameterDialog
        rootItem: _root
        x: (_root.width - width) / 2
        y: (_root.height - height) / 2
        z: QGroundControl.zOrderTopMost + 10
    }

    // 日志信息弹窗
    LogDialog {
        id: logDialog
        rootItem: _root
        x: (_root.width - width) / 2
        y: (_root.height - height) / 2
        z: QGroundControl.zOrderTopMost + 10
    }

    // 重点信息栏配置弹窗（共享实例，供地图右键菜单和仪表盘下方容器使用）
    ConfigMenu {
        id: configMenu
        x: (_root.width - width) / 2
        y: (_root.height - height) / 2
        z: QGroundControl.zOrderTopMost + 10
    }




    // 航线规划弹窗
    RoutePlanDialog {
        id: routePlanDialog
        mapControl: mapControl
        x: (_root.width - width) / 2
        y: (_root.height - height) / 2
        z: QGroundControl.zOrderTopMost + 10
    }

    //===== 参数显示侧拉框 =====
    //在 FlyView 里加一个隐形参考元素,作为参数显示框的锚点
    Item {
        id: panelAnchor
        // 顶部对齐主界面顶部
        anchors.top: parent.top
        // 底部对齐 SideToolbar 顶部 → 这样这个 Item 的高度就是两者间距
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 4
        visible: false   // 看不见，只用来当锚点
    }
    ParameterDrawer {
        id: parameterDrawer
        anchors.left: panelAnchor.left
        anchors.verticalCenter: panelAnchor.verticalCenter
        //anchors.centerIn : panelAnchor
        activeVehicle: _activeVehicle
        z: QGroundControl.zOrderTopMost + 2
    }

    // 外部通过此方法打开地图配置弹窗
    function showMapConfig() {
        mapConfigDialog.open()
    }

	// 外部通过此方法打开发动机配置弹窗
    function showEngineConfig() {
        engineConfigDialog.open()
    }
    // 外部通过此方法打开PWM通道配置弹窗
    function showPWMConfig() {
        pwmConfigDialog.open()
    }
    // 外部通过此方法打开串口功能配置弹窗
    function showSerialConfig() {
        serialConfigDialog.open()
    }
    // 外部通过此方法打开全部参数弹窗
    function showParameterDialog() {
        parameterDialog.open()
    }
    // 外部通过此方法打开日志信息弹窗
    function showLogDialog() {
        logDialog.open()
    }
    // 外部通过此方法打开航线规划弹窗
    function showRoutePlan() {
        routePlanDialog.open()
    }

    // 切换网格显示
    function toggleGrid() {
        _showGrid = !_showGrid
        if (_showGrid) {
            gridCanvas.requestPaint()
        }
    }

    property bool _showGrid: false

}
