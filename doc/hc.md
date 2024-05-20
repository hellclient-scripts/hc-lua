# 用户接口一览

## Hclua.HC.eventBus

说明:hclua的全局事件总线

引入模块:runtime/world

相关参考:[eventBus API](../src/hclua/lib/eventbus/README.md)

## Hclua.HC.isConnected

说明:判断游戏是否连接

引入模块:runtime/world

## Hclua.HC.connect

说明:连接游戏服务器，具体表现由客户端决定

引入模块:runtime/world

## Hclua.HC.disconnect

说明:断开游戏服务器连接，具体表现由客户端决定

引入模块:runtime/world

## Hclua.HC.exec

说明:调用Hclua.commands中注册的指令

引入模块:runtime/runtime

相关参到[commands API](../src/hclua/lib/commands/README.md)

## Hclua.HC.history

说明：行信息历史组件

引入模块:modules/core/histosy/install.lua

相关参考:[history API](../src/hclua/compontent/history/README.md)

## Hclua.HC.recorder

说明: 行信息记录器组件

引入模块:modules/core/histosy/install.lua

相关参考:[history API](../src/hclua/compontent/history/README.md)

## Hclua.HC.lineutils

说明：行信息数组工具

引入模块:modules/core/histosy/install.lua

相关参考:[lineutils API](../src/hclua/compontent/lineutils/README.md)

## Hclua.HC.newMetronome

说明:创建绑定到客户端的节拍器。注意，需要install才会开始正常工作

引入模块:modules/core/metronome/metronome.lua

相关参考:[metronome API](../src/hclua/compontent/metronome/README.md)

## Hclua.HC.installMetronome

说明:将Hclua.HC.newMetronome创建的节拍器安装到客户端中

引入模块:modules/core/metronome/metronome.lua

相关参考:[metronome API](../src/hclua/compontent/metronome/README.md)

## Hclua.HC.uninstallMetronome

说明:将Hclua.HC.newMetronome创建的节拍器从客户端中卸载

引入模块:modules/core/metronome/metronome.lua

相关参考:[metronome API](../src/hclua/compontent/metronome/README.md)

## Hclua.HC.sender

说明：游戏默认节拍器

引入模块:modules/core/metronome/install.lua

相关参考:[metronome API](../src/hclua/compontent/metronome/README.md)

## Hclua.HC.send

说明：将指令send到默认节拍器，用于取代客户端默认的send指令

引入模块:modules/core/metronome/install.lua

相关参考:[metronome API](../src/hclua/compontent/metronome/README.md)

## Hclua.HC.queue

说明：将指令push到指定节拍器,发送前会dicard并resume节拍器。第二个参数为节拍器，为nil则使用默认节拍器

引入模块:modules/core/metronome/install.lua

## hclua.HC.line

说明：将给到的字符串按行切割为指令组，方便用[[]]长字符格式为Hclua.HC.queue发送指令。第二个参数为true则分号也会分割。

引入模块:modules/core/metronome/install.lua

## runtime.HC.metronomeCommands
说明: 默认的节拍器指令.包含一个decoder和一个converter

引入模块:modules/core/metronome/commands.lua