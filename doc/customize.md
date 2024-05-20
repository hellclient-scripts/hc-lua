# 定制 HCLua

在loader成功加载HCLua后，我们可以通过调整HCLua的内容才对HCLua进行定制

## 自定义全局变量

供用户脚本调用的API都是放在全局函数变量的Hclua.HC 内的。

为了方便使用，建议用一个全局别两做个别名，比如

```hclua
H = Hclua.HC
```
这样在使用时能快速简便很多

## 自定义别名

HCLua默认会注册一个#hclua 开头的别名，可以通过 进行#hclua stop,#hclua help，#hclua xxx xxxx等形式进行调用。

但过长，建议参考#hclua的格式注册一个比较短的别名

比如 

```
^$((\S+)(\s+(.+))?)?$
```

这样使用$stop $help $xxx xxxx的形式调用别名内容。

## 定制加载的module

loader脚本中会使用Hclua:loadModules函数来加载脚本，代码一半如下
```lua
Hclua:loadModules(
    'module1',
    'module2',
    'module3',
)
```

在模块名前使用 -- 进行注释，就能屏蔽指定的模块的加载。

关于当前版本可用模块的说明，见[模块说明](modules.md)

## 关闭和开启全局触发/定时器

HCLua有部分高级功能依赖^.*$的触发和0.1秒的计时器进行触发的。

如果你确定不使用这些额外功能，觉得不想浪费性能，可以关闭这些功能

具体可以将loader里的 Hclua.world:enableEventLine(行触发) 和 Hclua.world:enableEventTick(定时器) 函数的参数从true改为false

**注意，强烈不建议这么做。**

## 下一步

[使用Hclua](use.md)