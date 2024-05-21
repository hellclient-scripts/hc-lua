# runtime 运行时

本模块是Hclua的基础框架

## Module 模块全局属性

### Module.path 
HCLua目录的引用位置

runtime:require和runtime:requireModule都是从这个位置开始计算引用路径的

### Module.versionMajor,Module.versionMinor,Module.versionPatch

HCLua的主版本号，子版本号和补丁号。

三个值都为数字类型

### Module.version

返回文字化的版本号，一般通过runtime对象的Module调用。

```lua
print(runtime.Module.version)
```

### Module.versionBefore

判断当前版本是否早于给到的大版本号，子版本号和补丁号，一般通过runtime对象的Module调用。

```lua
if (runtime.Module.versionBefore(0,20770101)) then
    print('Feature XXX not supported')
end
```

## runtiem对象

runtime指整个HCLua的代码包。一般情况下，整个runtime会安装到全局变量Hclua中。

### runtime.Module

返回 模块对象，方便调用全局属性

```lua
local module=runtime.Module
```

### runtime.world

runtime.world对象存放了客户端抽象类world,用来实现各种客户端专属的动作

### runtime.HC

runtime.HC是一个用来存放所有Hclua模块对用户API的入口

### runtime.commands

runtime.commands是一个内建的指令组，默认对接了 #hclua COMMANDNAME COMMANDPARAM 的别名

内建一个help别名，可以根据需要注册其他别名

### runtime.require

引用模块。

传入的参数应该位于模块全局属性 path下的想对路径，必须指向lua文件名

同名文件不会重复引用

```lua
local module=runtime:require('modulepath')
```