import QtQuick 2.0

// 高度表（Altimeter）
// 显示飞机当前高度，支持刻度尺滚动、高度预设标记和数字读数
Item {
    // 组件尺寸 300x300
    width: 300
    height: 300

    // 缩放比例
    property double scaleRatio: 1

    // 当前高度
    property double altitude: 0
    // 预设高度标记值（Bug值）
    property double bugValue: 0

    // 高度范围定义
    property double maximumAltitude: 99999
    property double minimumAltitude: 0
    // 小刻度线步长（每 100 单位一条刻度线）
    property double tickmarkStepSize: 100
    // 数字标签步长（每 500 单位显示一个标签）
    property double labelStepSize: 500

    // 刻度线总数量
    readonly property int tickmarkCount: (maximumAltitude - minimumAltitude) / tickmarkStepSize
    // 可见区域内刻度线数量
    readonly property int visibleTickmarkCount: 175 / (tickmarkStepSize * pixelPerAltitude)

    // 数字标签总数量
    readonly property int labelCount: (maximumAltitude - minimumAltitude) / labelStepSize
    // 可见区域内数字标签数量
    readonly property int visibleLabelCount: 175 / (labelStepSize * pixelPerAltitude)

    // 每单位高度对应的像素数（像素/高度单位）
    readonly property double pixelPerAltitude: 0.150

    // Bug标记相对于当前高度的 Y 轴偏移（像素）
    property double altitudeBugDeltaY: 0

    // 高度或Bug值变化时重新计算
    onAltitudeChanged: update()
    onBugValueChanged: update()

    // 更新Bug标记位置并重绘
    function update() {
        // 计算Bug标记的像素偏移
        altitudeBugDeltaY = pixelPerAltitude * (altitude - bugValue)

        // 限制Bug标记偏移范围 [-85, 85]
        if (altitudeBugDeltaY < -85.0)
            altitudeBugDeltaY = -85.0
        else if (altitudeBugDeltaY > 85.0)
            altitudeBugDeltaY = 85.0

        // 请求重绘 Canvas
        canvas.requestPaint()
    }

    // 高度刻度 - 使用 Canvas 动态绘制
    Canvas {
        id: canvas
        x: 231
        y: 37.5
        // Canvas 尺寸随缩放比例调整
        width: 36 * scaleRatio
        height: 175 * scaleRatio
        // 反向缩放，保证内部绘制坐标不变
        scale: 1 / scaleRatio
        transformOrigin: Item.TopLeft

        antialiasing: true
        onPaint: {
            var ctx = getContext('2d')
            ctx.reset()

            // 应用缩放
            ctx.scale(scaleRatio, scaleRatio)

            // 背景填充
            ctx.fillStyle = "#343434"
            ctx.fillRect(0, 0, 36, 175)

            // 平移坐标系，使当前高度对应到画布中心
            ctx.translate(0, altitude * pixelPerAltitude)

            // 下半部分（地面）填充
            ctx.fillStyle = "transparent"
            ctx.fillRect(0, 0.5 * 175, 36, 0.5 * 175)

            // 绘制白色刻度线
            ctx.strokeStyle = "#ffffff"
            ctx.lineWidth = 1

            // 计算可见范围内刻度线的起始和结束索引
            var lowestIndex = Math.round((altitude - minimumAltitude) / tickmarkStepSize - visibleTickmarkCount / 2)
            var highestIndex = Math.round(lowestIndex + visibleTickmarkCount)

            if (lowestIndex < 0)
                lowestIndex = 0

            // 逐条绘制刻度线
            for (var i = lowestIndex; i <= highestIndex; i++) {
                ctx.beginPath()
                ctx.moveTo(0, 0.5 * 175 - i * tickmarkStepSize * pixelPerAltitude)
                ctx.lineTo(6, 0.5 * 175 - i * tickmarkStepSize * pixelPerAltitude)
                ctx.stroke()
            }

            // 绘制高度数字标签
            ctx.textAlign = "right"
            ctx.textBaseline = 'middle'
            ctx.fillStyle = "#ffffff"

            // 计算可见范围内标签的起始和结束索引
            lowestIndex = Math.round((altitude - minimumAltitude) / labelStepSize - visibleLabelCount / 2)
            highestIndex = Math.round(lowestIndex + visibleLabelCount)

            if (lowestIndex < 0)
                lowestIndex = 0

            // 逐条绘制数字标签
            for (i = lowestIndex; i <= highestIndex; i++) {
                var valueString = i * labelStepSize
                valueString = valueString.toFixed(0)

                // 根据数字位数调整字体大小，保证显示完整
                if (valueString.length < 4)
                    ctx.font = "11px 'Courier Std'"
                else if (valueString.length === 4)
                    ctx.font = "10px 'Courier Std'"
                else
                    ctx.font = "9px 'Courier Std'"

                ctx.fillText(valueString, 34, 0.5 * 175 - i * labelStepSize * pixelPerAltitude)
            }
        }
    }

    // 预设高度标记（Bug）- 相对于当前高度上下移动
    CustomImage {
        id: alt_bug
        x: 225
        y: 110
        height: 30
        source: "/qmlimages/eadi_alt_bug.svg"
        sourceSize.height: 150
        sourceSize.width: 375
        transform: Translate {
            // 根据高度差动态偏移
            y: altitudeBugDeltaY
        }
    }

    // 高度表外框
    CustomImage {
        id: alt_frame
        x: 225
        y: 110
        height: 30
        source: "/qmlimages/eadi_alt_frame.svg"
        sourceSize.height: 150
        sourceSize.width: 375
    }

    // 当前高度数字显示
    Text {
        x: 241
        y: 119
        width: 31
        height: 11
        // 显示当前高度，保留整数
        text: altitude.toFixed(0)
        font.family: "Courier Std"
        font.pixelSize: 16
        horizontalAlignment: Text.AlignHCenter
        color: "#ffffff"
        antialiasing: true
    }

    // 下遮罩 - 遮挡刻度超出部分
    Rectangle {
        id: mask1
        x: 225
        y: 212
        width: 42
        height: 12
        color: "transparent"
    }

    // 上遮罩 - 遮挡刻度超出部分
    Rectangle {
        id: mask2
        x: 225
        y: 26
        width: 42
        height: 12
        color: "transparent"
    }
}