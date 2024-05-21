# 扩展开发

在进行扩展开发时，有如下建议点

## 使用hclua的requireModule机制加载模块

requireModule机制能避免重复加载，同时能将当前运行环境传给模块。

[参考连接](../src/hclua/runtime/README.md)

## 扩展模块不要放在hclua文件夹内

HCLua设计是直接替换hclua文件夹进行更新，再微调loader，放在文件夹内在更新时容易冲突

## 不要使用客户端的触发和计时器

使用客户端的触发和计时器容易污染用户的脚本空间，建议如下处理
* 监听Hclua.HC.eventBus的'world.line'事件，代替触发功能
* 监听Hclua.HC.eventBus的'world.tick'事件，配合Hclua.world.getTime()，代替计时器的功能

## 使用Hclua.HC使用

所有供客户端提供的功能理论上应该插入Hclua.HC上，方便直接调用

[参考连接](hc.md)

## 模块名事件时带上合适的命名空间

目前HCLua自带的事件都是world.开头和core.开头的，能方便的定位到具体的责任模块。

使用自定义模块或者事件时也建议使用合适的前缀名