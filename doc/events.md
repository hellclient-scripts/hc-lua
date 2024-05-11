# HCLua 事件清单

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

## world.lineInit

由hclua/world/world.lua发起

发起时间点为客户端接收到新行后，world.line触发前

参数为接受到的新行转换的line对象

用途为初始化接受到的行对象，正式的触发不应该加在这个事件内

## world.line

由hclua/world/world.lua发起

发起时间点为客户端接收到新行后，world.lineInit触发之后，world.lineReady触发前

参数为接受到的新行转换的line对象

用途为触发和处理休息的输出，执行具体代码

## world.lineReady

由hclua/world/world.lua发起

发起时间点为客户端接收到新行后，world.line触发之后

参数为接受到的新行转换的line对象

用途为在主流程触发完毕后，进行收尾工作