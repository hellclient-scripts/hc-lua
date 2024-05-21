# HCLua API一览

## 用户接口

所有设计中直接供用户在客户端调用的接口都在全局变量hclua.HC中

建议将较短的全局变量值设为hclua.HC,方便调用

[查看详细说明](../doc/hc.md)

## 系统接口

* [runtime 底层框架](../src/hclua/runtime/README.md)
* [world 客户端接口](../src/hclua/world/world.lua)

## lib 库
* [commands 指令管理库](../src/hclua/lib/commands/README.md)
* [container 容器库](../src/hclua/lib/container/README.md)
* [eventbus 事件总线库](../src/hclua/lib/eventbus/README.md)
* [line 游戏行信息库](../src/hclua/lib/line/README.md)

## component 组件
* [history 历史行信息组组件](../src/hclua/compontent/history/README.md)
* [lineutils 行信息工具组件](../src/hclua/compontent/lineutils/README.md)
* [metronome 节拍器限流器组件](../src/hclua/compontent/metronome/README.md)