# history 行信息历史组件

行信息历史组件是为了能够方便的进行多行处理，监听客户端的line事件，并提供一个 从新向旧获取多行行信息的的history组件，以及 从旧向新获取多行行信息的recorder组件。

使用时，需要监听客户端的line事件，并调用history的online方法。

使用recorder需要通过history创建，并在销毁时调用detach方法

## history 历史组件

历史组件在创建时需要指定长度。

超过长度后，最旧的信息会被覆盖。

如果更改长度，必须调用flush方法后才能生效新长度。


### history 创建历史组件

创建历史组件时需要指定长度

```lua
    local history=runtime:requireModule('compontent/history/history.lua')
    local hi=history.new(200)
```
### history 获取长度

获取历史组件的长度

```lua
print(li:getLength())
```

### history 设置长度

设置历史组件的长度。

新长度在调用flush方法后才会生效。

返回组件本身，方便链式调用

```lua
li:withLength(999)
```

### history 清空记录

清空历史组件的记录。

清空后新的长度才会生效
```lua
hi:flush()
```

### history 行信息绑定函数

必须正确的在新行到来时调用onLine函数，才能让历史组件及相关的记录器正常工作

```lua
runtime.HC.bind('world.line',function(line)
    hi:online(line)
end)
```

### history 获取当前行

获取当前行信息(最后一次online传递过来的内容)

```lua
local line=hi:current()
```

### history 获取行信息数组

获取指定行信息数组。

第一个参数为需要获取的内容的最大行数

第二个参数为，相对于最新行的偏移量,偏移量最小为0,最大为历史组件长度，默认为0

返回值为对应长度，偏移后的新信息在后的行信息数组。

如果行历史不足，可能会获取少于行度的数组。

如果偏移量无效，则返回空

```lua
local lines=hi:getLines(10,4) --获取倒数第5行及之前的10行内容
```


### history 创建记录器

创建绑定到当前历史组件的记录器(recorder)

创建的记录器在不使用时应该调用detach方法解绑

```lua
local recorder=hi:createRecorder()
recorder:detach()
```

## 记录器

与历史记录不同，记录器在调用开始方法后，开始记录最多指定的行数的行信息。

因此，记录器主要用于触发后开始记录信息。

记录器在会绑定到历史组件的事件总线上，响应所有的line事件。

因此，在不再使用时请调用detach方法

### recorder 创建

利用指定的历史组件创建记录器

一般使用history的createRecorder方法创建

```lua
local recorder=history.Recorder:new(hi)
recorder:detach()
```

### recorder 开始记录

记录器启动，开始记录最大cap行记录，并在记录满后调用传入的回调函数。

第一个参数cap时最多记录的行数，默认为1

第二个参数onfull为记录器满时掉用的回调，会将记录器本身作为为一参数传入，stop后不会调用。为nil不调用任何函数。

无返回值

```lua
recorder:start(99,function(r)
print('记录器满了')
print('记录器的cap为'..r:getCap())
end)
```

### recorder 获取最大记录行数

获取最后一次start时给定的cap

从来没start过或已经stop时会返回默认值0

```lua
print(recorder:getCap())
```

### recorder 获取已记录的行信息数量

获取已经记录的行信息数量
```
print(r:getLength())
```

### recorder 停止记录

手动停止记录

会将cap设置为0,onfull回调清空

不处理已经记录的数据

```lua
recorder:stop()
```

### recorder 获取已记录行信息数组

获取最后一次start后，新信息在后的行信息数组

```lua
local lines=recorder:getLines()
```

### recorder 获取记录器是否还在工作

通过cap和length数据判断记录器是否还在工作状态

```lua
local running=recorder:running()
```

### recorder 解除绑定

记录器不再使用后应该调用本方法

```lua
recorder:detach()
```