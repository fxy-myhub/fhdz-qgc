import QtQuick 2.15

// 航向指示器（HSI - Horizontal Situation Indicator）
// 显示当前航向和预设航向标记，通过旋转罗盘面来指示方向
Item {
    // 组件尺寸 300x300
    width: 300
    height: 300
    // 裁剪超出边界的部分
    clip: true

    // 当前航向角（度）
    property double heading: 0
    // 预设航向标记值（Bug值，相对于当前航向的偏移）
    property double bugValue: 0

    // 航向指示器背景
    CustomImage {
        id: back
        x: 0
        y: 210
        height: 90
        source: "/qmlimages/eadi_hsi_back.svg"
        sourceSize.height: 450
        sourceSize.width: 1500
    }

    // 罗盘刻度面 - 根据当前航向旋转
    CustomImage {
        id: face
        x: 38
        y: 233
        width: 224
        source: "/qmlimages/eadi_hsi_face.svg"
        sourceSize.height: 2240
        sourceSize.width: 2240

        // 旋转罗盘面，使当前航向始终指向顶部
        transform: Rotation {
            // 旋转中心点（相对于父容器的坐标）
            origin.x: (150 - 38)
            origin.y: (345 - 233)
            axis {
                x: 0
                y: 0
                z: 1
            }
            // 负角度旋转，使航向刻度正确对应
            angle: -heading
        }
    }

    // 预设航向标记（Bug）- 相对于航向面旋转
    CustomImage {
        id: bug
        x: 38
        y: 233
        width: 224
        source: "/qmlimages/eadi_hsi_bug.svg"
        sourceSize.height: 2240
        sourceSize.width: 2240
        transform: Rotation {
            origin.x: (150 - 38)
            origin.y: (345 - 233)
            axis {
                x: 0
                y: 0
                z: 1
            }
            // Bug标记角度 = 航向面旋转 + 预设偏移
            angle: -heading + bugValue
        }
    }

    // 固定刻度标记 - 始终不旋转，作为读取参考
    CustomImage {
        id: marks
        x: 134
        y: 217
        height: 73
        source: "/qmlimages/eadi_hsi_marks.svg"
        sourceSize.height: 730
        sourceSize.width: 320
    }

    // 航向数字显示
    Text {
        x: 136
        y: 219
        // 显示当前航向角度，保留整数
        text: heading.toFixed(0)
        width: 28
        height: 14
        font.family: "Courier Std"
        font.pixelSize: 16
        horizontalAlignment: Text.AlignHCenter
        // 红色数字显示
        color: "#ce2121"
        antialiasing: true
    }
}