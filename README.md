# 关于HCLua

HCLua是一款跨客户端的Lua机器人开发框架。

[快速上手](doc/quickstart.md)

## 优势
HCLua的优势为
* 模块化设计
* 跨客户端使用
* 屏蔽底层细节的统一开发体验
* 低侵入性，渐进式开发
* 充分的单元测试

### 模块化开发

HCLua内建一套独立于lua require系统的模块加载工具，能方便的进行模块加载/引用，并且不与原生require冲突。同时提供requireModule方法，加载为HCLua特殊设计的模块。

HCLua的代码提供4种级别的代码
* vendor 第三方库，可以直接引用使用
* lib 库文件，可以直接使用
* component 组件，需要通过HCLua框架引入，不涉及业务代码
* module 模块，需要通过HCLua框架引入，一般会与HCLua的运行时有一定的交互。

在加载HCLua时，可以通过调整loader加载函数，选择性的进行模块加载

### 跨客户端使用

HCLua通过代理的方式，将客户端事件和必要的接口转换为内容统一的格式，使得代码在不同客户端下直接使用成为可能。

理论上，只要支持
* lua5.1脚本
* 获取当前行文字以及样式
* 有高精度定时器(0.1秒)
* 毫秒级的计时器，可以判断两个时间点之间间隔多少毫秒、
* 连接和断开服务器的事件
* 获取当前连接状态
* 提供发送原始指令API
* 设置/获取持久化变量
的客户端，在适配后都可以使用HCLua

目前HCLua为Mushclient和Mudlet做了适配。

### 屏蔽底层细节的统一开发体验

HCLua将Mud机器人开发抽象为如下概念

* 行信息，包括文字，颜色，样式(加粗，斜体/闪烁,反转,下划线)，并提供行信息直接比较的方法
* 定时器(高频周期性执行)和计时器(计算两次计时器之间的间隔)，适用于需要高度控制时间的场合
* 统一的发送接口
* 统一的事件系统(连线事件，断线事件，定时器事件，新文字行事件)
* 统一的指令入口
* 客户端的类型和编码属性

在统一的抽象层开发使得开发的注意力容易集中，能方便的模拟服务器反映进行单元测试，以及更好的代码通用性。

### 低侵入性，渐进式开发

HCLua在开发时注重低侵入性，尽量不影响原有代码的功能。一般而言，HCLua对机器人的侵入表现在
* 一个命名为hclua开头的高优先级响应所有文字的触发，用于接受行信息
* 一个命名为hclua开头的timer,用于触发定时器
* 一个以^#hclua 开头的正则别名，用于提供一定的指令帮助
* 一个hclua的lua全局变量，用于存储所有的HCLua相关的数据和函数
* 响应连接和断开连接的设计

根据不同的客户端，根据特性可能还有一些其他的侵入性设计，具体会在安装页列出

### 充分的单元测试

在项目代码的test目录内，有所有的lib和component的测试代码，以及部分方便测试的module

测试代码除了验证代码质量，还负责提供使用Demo，以及兼容性保证的功能。

## 特性


[详情](doc/features.md)

## 可选模块

### history 历史文本管理

history模块的功能包括：

* 记录了最近的历史行信息，可以从新向旧方向进行截取
* 提供一个记录器，可以手动开始记录行信息，从旧向新进行截取
* 提供了列操作，可以将截取出的行信息，根据gbk/utf8显示宽度，进行指定列之间的横向截取

通过history模块，能很方便的进行历史信息分析，多行回答分析，色彩统计，图像比较等功能

### metronome 节拍器 可编程限流发送队列

metronome模块的功能包括

* 高效的模拟心跳发送限流，在指令数波动较大时比固定间隔的speedwalk更有效率，在绝大部分场合能取代speedwalk的功能。
* 提供指令分组功能，将同一组的指令在同一时刻发出，避免固定间隔队列容易遇到的间隔过长场景/npc发生变化的尴尬。
* 提供暂停/继续/步进/重发等队列控制功能，能在大部分场合下替代指令队列的功能
* 提供精细的限流控制，可以较为精确地对发送频率进行控制。
* 提供指令解码功能，可以实现各种自定义指令，比如模拟Zmud的#wait,#t+,#t-指令
* 提供管道功能，可以将多个不同频率的节拍器重定向到主节拍器上，进行不同频率的限流，可以在不严格的场合实现移动限速等功能。
* 提供指令转换功能，实现管道重定向多个节拍器时，将不同的指令算做不同的指令数，实现更精确的频率控制。


## 文档

* [快速上手](doc/quickstart.md)
* [模块一览](doc/modules.md)
* [API一览](doc/api.md)
* [事件清单](doc/events.md)