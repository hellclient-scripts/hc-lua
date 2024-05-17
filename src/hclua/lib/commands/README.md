# commands 指令组库

指令组是一个简单的注册指令并调用的库

指令包括

* id,就是具体的指令
* intro 短描述，用于在指令列表里做说明
* desc 描述，一般用于查看具体说明
* fn 具体的调用函数

## commands 创建指令组

创建一个空的指令组

传入的参数为默认处理函数，必填，格式为

```lua
function defaultfn(id,data)
end
```

用于没有找到匹配指令时进行处理。

可以用来做人性化错误提示

```lua
function defaultfn(id,data)
    print('指令 ['..id..']没找到。')
end
local commands=require('commands.lua')
local cmds=commands.new(defaultfn)
```

## commands 添加指令

将给到的指令id和指令函数注册为指令

返回值为注册后的command

已经注册过的同名command会被替代

```lua
function newcommand(data)
    print(data)
end
local cmd=cmds:register('echo',newcommand)
```
## commands 执行指令

用给到的id和参数去执行指令

会根据id去调用已注册指令的fn函数，将参数传入。

如果id未注册，会将id和参数传给默认函数执行

返回指令的fn或者默认指令的返回值

```lua
    local result=cmds:exec('echo','value')
```

## commands 获取指令

获取指定id的指令对象。

如果id未注册，则返回nil

```lua
    local cmd=cmds:getCommand('id')
```

## commands 移除指令

移除指定id的指令

无返回值

```lua
    cmds:remove('id')
```

## commands 列出指令列表

按注册顺序列出指令

返回值为 command对象的数组

```lua
    local list=cmds:list()
    for index, value in ipairs(list) do
        print(value.id())
    end
```

## command 创建指令

一般情况下使用commands的register方法创建并注册新指令

```lua
    local cmd=commands.Command:new(id,fn)
```

## command 执行指令

将给到的参数才传递给指令的fn，并返回返回值

```lua
local result=cmd:exec('data')
```

## command 返回指令id

返回值为字符串

```lua
    print(cmd:id9)
```

## command 设置指令说明

设置指令的Intro

方便链式调用，返回command本身

```lua
    local cmd=commands.Command:new():withIntro('some intro')
```

## command 返回指令说明

返回指令的说明

一般用于列表中的简介

```lua
print(cmd:intro())
```

## command 设置指令描述

设置指令的Desc

方便链式调用，返回command本身

```lua
    local cmd=commands.Command:new():withDesc('some desc')
```

## command 返回指令描述

返回指令的说明

一般用于现实指令的详细说明

如果未设置，则返回指令的intro

```lua
print(cmd:desc())
```