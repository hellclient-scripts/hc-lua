# 模块列表

## 历史行信息模块

### modules/core/history/install.lua

本模块的开发目的是方便用户操作历史行信息数组。

引入本模块后有如下效果:

1. 创建了Hclua.HC.history,一个大小为200的信息历史组件 [查看文档](../src/hclua/compontent/history/README.md)
2. 创建了Hclua.HC.recorder,一个基于默认历史组件的记录器 [查看文档](../src/hclua/compontent/history/README.md)
3. 创建了Hclua.HC.lineutils,一个操作行信息的工具库 [查看文档](../src/hclua/compontent/lineutils/README.md)

利用Hclua.HC.history,可以在触发关键字后，倒查N行历史信息(getLines)。

利用Hclua.HC,recorder，可以在触发关键字后，开始(start)记录，触发另一个关键字后停止(stop)记录，并取出所有及记录信息(getLines)

利用Hclua.HC.lineutils,可以快速的合并行数组文本(combineLines)或短描述(combineLinesShort),可以快速的进行矩形裁切(sliceLines或linesUTF8Mono)

## 指令模块

### modules/core/commands/install.lua

本模块提供了一些通用的指令

目前仅引入一个stop指令，调用后会抛出一个core.stop指令，供业务代码监听并停止工作

## 节拍器模块

### modules/core/metronome/metronome.lua

本模块提供了一个创建，绑定和解绑封装过的节拍器的功能

```lua
local m=Hclua.HC.newMetronome()
```
创建节拍器

```lua
Hclua.HC.installMetronome(m)
```
绑定节拍器

```lua
Hclua.HC.uninstallMetronome(m)
```
解绑节拍器

这个模块主要是被依赖使用，以及创建管道重定向到主节拍器的分节拍器

### modules/core/metronome/install.lua

安装本模块会自动安装 'modules/core/metronome/metronome.lua' 模块

本模块会安装一个默认节拍器，并注册部分辅助API

```lua
Hclua.HC.sender
```

Hclua.HC.sender是默认的标准节拍器,参考 [metronome文档](../src/hclua/compontent/metronome/README.md)

```lua
Hclua.HC.send('my command')
```
Hclua.HC.send可以调用默认节拍器的send方法，直接发送指令。

```lua
Hclua.HC.queue(Hclua.HC.lines([[
    commad1
    command2
]]))

Hclua.HC.queue(Hclua.HC.lines(
    "commad1;command2;command3"
    ),true)
```
Hclua.HC.queue的用途是初始化默认节拍器并发送一系列指令
* 第一个参数为字符串列表，每个元素一个指令
* 第二个参数为要发送的节拍器，默认为主节拍器

Hclua.HC.lines的工作是把字符串，特别是[[]] 包裹的长字符串切割为Hclua.HC.queue适用的指令数组
* 第一个参数为长字符串
* 第二个参数为true时分号;也会分割为行，否者只分割换行符


### modules/core/metronome/commands.lua