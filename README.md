# QGroundControl Ground Control Station

[![Releases](https://img.shields.io/github/release/mavlink/QGroundControl.svg)](https://github.com/mavlink/QGroundControl/releases)
[![Travis Build Status](https://travis-ci.org/mavlink/qgroundcontrol.svg?branch=master)](https://travis-ci.org/mavlink/qgroundcontrol)
[![Appveyor Build Status](https://ci.appveyor.com/api/projects/status/crxcm4qayejuvh6c/branch/master?svg=true)](https://ci.appveyor.com/project/mavlink/qgroundcontrol)

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/mavlink/qgroundcontrol?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


*QGroundControl* (QGC) is an intuitive and powerful ground control station (GCS) for UAVs.

The primary goal of QGC is ease of use for both first time and professional users.
It provides full flight control and mission planning for any MAVLink enabled drone, and vehicle setup for both PX4 and ArduPilot powered UAVs. Instructions for *using QGroundControl* are provided in the [User Manual](https://docs.qgroundcontrol.com/en/) (you may not need them because the UI is very intuitive!)

All the code is open-source, so you can contribute and evolve it as you want.
The [Developer Guide](https://dev.qgroundcontrol.com/en/) explains how to [build](https://dev.qgroundcontrol.com/en/getting_started/) and extend QGC.


Key Links:
* [Website](http://qgroundcontrol.com) (qgroundcontrol.com)
* [User Manual](https://docs.qgroundcontrol.com/en/)
* [Developer Guide](https://dev.qgroundcontrol.com/en/)
* [Discussion/Support](https://docs.qgroundcontrol.com/en/Support/Support.html)
* [Contributing](https://dev.qgroundcontrol.com/en/contribute/)
* [License](https://github.com/mavlink/qgroundcontrol/blob/master/COPYING.md)
##更新日志
###2026-08-13-fxy：FHDZ-QGC-v0.1.21  
- feat(popupchange):修改弹窗model：false，退出功能仅支持esc与关闭按钮，取消弹窗区域外点击关闭策略

###2026-08-12-fxy：FHDZ-QGC-v0.1.20  
- V00：最初拉取的 可编译成功  
- V01：汉化完成  
- V02：成功添加工具栏  
- V03：添加菜单栏 菜单栏与工具栏分文件编写  添加常用遥测时间显示 更换LOGO图标  
- V04：添加常用遥测按钮 删掉了主界面其他组件  
- V05：添加高德地图 实现工具栏 选择工具  放大地图 缩小地图 移动地图功能  
- V06：添加了距离测量功能 添加了经纬度显示功能  
- V07：添加了右下角串口连接功能   实现了 二维地图配置功能(更换地图   定位)  
- V08：实现地图网格显示 功能  
- V09：实现了航线规划弹窗也页面显示 双击定位航点  
- V10：实现了串口通信连接 添加MAVLink程序相关注释  
- V11：添加新的仪表盘  
- V12：调整了 仪表盘BUG  
- V13：修改了 分辨率适配问题     增加功能 鼠标右击地图出现菜单栏 （定位飞机 距离测量 清除轨迹 退出） 
- V14：鼠标右击屏幕 弹出菜单栏 菜单栏中 配置按钮实现 发动机 姿态 GPS  
- V15：添加了发动机配置界面  
- V16：界面左侧添加信息显示栏，添加背景主题light/dark切换设置，修改现有控件背景贴合主题切换  
- V17：修改了遥测显示布局 修正了航线规划  
- V18：菜单栏添加了初始配置 并实现了PWM通道页面   遥测数据配置（右击遥测容器 配置按钮 ）航线规划边框缩放  程序合并 实现主题设置（白天和黑夜）  
- V20：优化左侧参数显示栏，界面底部添加功能按钮



