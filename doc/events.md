# HCLua 事件清单

所有的事件通过Hclua.world.eventBus或Hclua.HC.eventBus 绑定

## world.connect 事件

由客户端对应的world实现文件发起

发起时间点为在游戏成功连接时

无参数

用途为唤起连接处理的脚本

## world.disconnect 事件

由客户端对应的world实现文件发起

发起时间点为在游戏断开连接时

无参数

用途为唤起断线处理的脚本

## world.tick 事件

由客户端对应的world实现文件发起

发起时间点为客户端内建的timer每0,1秒调用一次

无参数

用途为配合HCLua.world.getTime(),实现高精度的定时任务控制。

## world.lineInit 事件

由hclua/world/world.lua发起

发起时间点为客户端接收到新行后，world.line触发前

参数为接受到的新行转换的line对象

用途为初始化接受到的行对象，正式的触发不应该加在这个事件内

## world.line 事件

由hclua/world/world.lua发起

发起时间点为客户端接收到新行后，world.lineInit触发之后，world.lineReady触发前

参数为接受到的新行转换的line对象

用途为触发和处理休息的输出，执行具体代码

## world.lineReady 事件

由hclua/world/world.lua发起

发起时间点为客户端接收到新行后，world.line触发之后

参数为接受到的新行转换的line对象

用途为在主流程触发完毕后，进行收尾工作

## core.stop 事件

由hclua/modules/core/commands/install.lua发起

发起时间为用户输入#hclua stop指令后

参数为#hclua stop后的字符串数据

用途为提供一个通用的停止脚本工作运行的指令

用户的自定义脚本可以通过响应本事件实现停止脚本运行的功能

## core.metronome.sent 事件

由hclua/modules/core/metronome/commands.lua发起

发起时间为主节拍器发送成功调用Converter时

参数为主节拍器

用途为供在界面显示待发送的指令