# HCLua 特性

## 模块管理

由于lua本身模块加载的全局性，与HCLua的低侵入性目标相冲突。所以Hclua维护了自己的一套模块引入机制。

首先，所有引入文件的位置由Hclua.path决定，在客户端Loader加载程序加载时会进行相应设置

然后，HCLua提供了Hclua:require和Hclua:requireModule两种引入模块的方式

* Hclua:require 直接引入指定的lua文件
* Hclua:requreModule 模块文件返回加载函数，Hclua会将整个运行时传入，将返回值当作模块本体

## 事件系统

HCLua提供了一个事件总线Hclua.world.eventBus或Hclua.HC.eventBus

可以直接进行事件的抛出，绑定，以及转发,提供了全局的事件处理机制

[事件参考](../src/hclua/lib/eventbus/README.md)

## 行信息

HCLua的客户端适配脚本会将客户端传入的行信息及相应样式 转换为行信息格式，通过相应事件传给需要处理的程序

[行信息参考](../src/hclua/lib/line/README.md)

为了方便使用，行信息会通过三个事件进行传递

* world.lineInit
* world.line
* world.lineReady

方便进行简单的顺序控制

## tick事件

HCLua的客户端适配脚本会定期抛出world.tick事件，配合Hclua.world.getTime()能实现定时器的操作，具体为

* 将getTime()+计时器的周期,生成下一次生效时间(next)
* 在tick里判断是否达到下一次生效时间，达到则调用回调并重置或取消计时器

实现对远客户端脚本的低侵入

## 指令系统

HCLua提供了一个指令系统 HCLua.commands，绑定到别名#hclua 可供注册各种指令，并提供了基本help指令。

方便自行制作的模块加入命令行指令

[指岭组参考](../src/hclua/lib/commands/README.md)