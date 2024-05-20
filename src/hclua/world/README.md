# world 客户端类

world类是用来体现客户端通用功能的抽象类。

Hclua.world就是代表的当前客户端的类

## world:send

发送原始数据
```lua
    world:send('some command')
```

## world:readUserfile

读取用户文件，第一个参数为文件名
```lua
    local data=Hclua.world:readUserFile('myfile.txt')
```

## world:writeUserfile

写入用户文件，第一个参数为文件名,第二个参数为具体数据
```lua
    local data=Hclua.world:readUserFile('myfile.txt',mydata)
```

## world.eventBus

客户端的事件总线，使用时会复制到Hclua.HC.eventBus

## world:enableTriggers

批量激活触发器，第一个参数为触发器组名

```lua
Hclua.world:enableTriggers('GROUPNAME')
```

## world:disableTriggers

批量禁用触发器，第一个参数为触发器组名

```lua
Hclua.world:disableTriggers('GROUPNAME')
```

## world:setVariable
设置变量值,第一个参数为变量明，第二个参数为变量值
```lua
Hclua.world:setVariable('VARNAME','VARVALUE')
```

## world:getVariable
获取变量值。如果值不存在，则应该返回空字符串。
```lua
local value=Hclua.world:getVariable('VARNAME')
```

## world:print
打引文字到mud界面,第一个参数为打引的内容
```lua
Hclua.world:print('MY DATA')
```

## world:getTime
获取毫秒级的时间值，用于确定两个tick之间过去了多少时间
```lua
print(Hclua.world:getTime())
```

## world:enableEventLine

启用行信息事件，设为true则行信息有效，否则无效。一般用于loader自定义。
```lua
Hclua.world:enableEventLine(true)
```

## world:enableEventTick

启用心跳事件，设为true则心跳信息有效，否则无效。一般用于loader自定义。
```lua
Hclua.world:enableEventTick(true)
```

## world:withCommandPrefix

设置命令前缀，默认是'#hclua ',一般用于loader自定义。

返回world本身，方便链式调用。

```lua
Hclua.world:withCommandPrefix('$')
```

## world:getCommandPrefix()

获取命令前缀，一般用于指令提示

```lua
print(Hclua.world:getCommandPrefix())
```

## world:connect()

连接到游戏
```lua
Hclua.world:connect()
```

## world:disconnect()

断开游戏连接
```lua
Hclua.world:disconnect()
```

## world:isConnected()

返回是否连接到游戏，true代表正在连接
```lua
print(Hclua.world:isConnected())
```