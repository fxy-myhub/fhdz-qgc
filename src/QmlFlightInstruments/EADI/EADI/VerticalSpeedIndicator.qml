import QtQuick 2.0

// 升降速度指示器（VSI - Vertical Speed Indicator）
// 显示飞机的爬升/下降速率，使用刻度尺和动态指示线来表示垂直速度
Item {
    // 组件尺寸 300x300
    width: 300
    height: 300

    // 缩放比例
    property double scaleRatio: 1
    // 爬升/下降速率，单位：m/s，范围 [-6, 6]
    property double climbRate: 0

    // 分段像素映射：0~1 m/s 范围内每单位对应 30 像素
    property double pixelPerSpeed1: 30
    // 分段像素映射：1~2 m/s 范围内每单位对应 20 像素
    property double pixelPerSpeed2: 20
    // 分段像素映射：2~6 m/s 范围内每单位对应 5 像素
    property double pixelPerSpeed4: 5

    // 指示线当前的 Y 坐标位置（零位为 75）
    property double lineY: 75

    // 爬升速率变化时重新计算指示线位置
    onClimbRateChanged: update()

    // 根据当前爬升速率计算指示线的 Y 坐标
    function update() {
        let lineDeltaY = 0
        let climbRateAbs = Math.abs(climbRate)

        // 采用分段线性映射：低速段灵敏度高，高速段压缩显示
        if (Math.abs(climbRate) <= 1.0) {
            // 0 ~ 1 m/s：像素偏移 = 30 * 速率
            lineDeltaY = pixelPerSpeed1 * climbRateAbs
        } else if (Math.abs(climbRate) <= 2.0) {
            // 1 ~ 2 m/s：像素偏移 = 30 + 20 * (速率 - 1)
            lineDeltaY = pixelPerSpeed1 + pixelPerSpeed2 * (climbRateAbs - 1.0)
        } else {
            // 2 ~ 6 m/s：像素偏移 = 30 + 20 + 5 * (速率 - 2)
            lineDeltaY = pixelPerSpeed1 + pixelPerSpeed2 + pixelPerSpeed4 * (climbRateAbs - 2.0)
        }

        // 下降时指示线向下移动（Y 增大）
        if (climbRate < 0)
            lineY = 75 + lineDeltaY
        // 爬升时指示线向上移动（Y 减小）
        else if (climbRate > 0)
            lineY = 75 - lineDeltaY
        // 速率为零时回中
        else
            lineY = 75

        // 请求重绘 Canvas
        canvas.requestPaint()
    }

    // 升降速度刻度尺背景
    CustomImage {
        x: 275
        y: 50
        width: 19
        source: "/qmlimages/eadi_vsi_scale.svg"
        sourceSize.height: 750
        sourceSize.width: 95
    }

    // 动态指示线 - 使用 Canvas 绘制
    Canvas {
        id: canvas
        x: 275
        y: 50
        // Canvas 尺寸随缩放比例调整
        width: 19 * scaleRatio
        height: 150 * scaleRatio
        antialiasing: true
        // 反向缩放，保证内部绘制坐标不变
        scale: 1 / scaleRatio
        transformOrigin: Item.TopLeft

        onPaint: {
            var ctx = getContext('2d')
            ctx.reset()

            // 应用缩放，使绘制内容在缩放后保持清晰
            ctx.scale(scaleRatio, scaleRatio)

            // 白色指示线
            ctx.strokeStyle = "#ffffff"
            ctx.lineWidth = 4
            ctx.beginPath()
            // 从中心零点位置开始
            ctx.moveTo(14.25, 75)
            // 画到当前速率对应的位置
            ctx.lineTo(14.25, lineY)
            ctx.stroke()
        }
    }
}