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

### runtime:require

引用模块。

传入的参数应该位于模块全局属性 path下的想对路径，必须指向lua文件名

同名文件不会重复引用

```lua
local module=runtime:require('modulepath')
```


### runtime:requireModule

通过模块模式引用模块

引入的文件会当作函数，传入runtime,并获得返回值

例:

```lua
function(runtime) 
    local M={}
    return m
end
```

### runtime:loadModules

批量导入模块，一般用于loader文件

```lua
Hclua:loadModules(
    'MODULE1',
    'MODULE2',
    'MODULE3',
)
```
同名文件不会重复引用

### runtime:loaded

判断某模块是否已经成功加载，返回值为布尔值

```lua
print(Hclua:loaded('MYMODULE'))
```

```lua
local module=runtime:requireModule('mymodule')
```

### runtime:getPath

返回加载根路径
### runtime:getCharset

返回客户端的编码

可能值包括
* utf8
* gbk

```lua
print(runtime:getCharset())
```

### runtime:getHostType

返回客户端的类型

可能的值包括
* mushclient
* mudlet

```lua
print(runtime:getHostType())
```