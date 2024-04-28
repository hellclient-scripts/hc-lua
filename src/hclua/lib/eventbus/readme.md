# 事件总线
该库用于简单的事件绑定和触发

## 创建总线
```lua
local eventbus=require('eventbus').new()
```

## 绑定事件处理函数

调用bindEvent函数可以将处理函数绑定到事件上。

处理函数可以多次绑定，触发时会多次触发

处理函数的格式应该为
```lua
function hanlder(content)
      ...
end
```
绑定方法

```lua
eventbus:bindEvent('eventkey',handler)
```

**特别注意:不应该依赖事件的绑定或触发顺序。**


## 触发事件

使用raiseEvent函数可以将上下文传递给每一个绑定过的事件处理函数

如果指定的事件没有绑定过处理函数，则什么也不会发生
```lua
eventbus.raiseEvent('eventkey',eventdata)
```

**特别注意:不保证事件触发时的前后处理关系。**

## 处理函数解绑定

通过unbindEvent可以将指定的处理函数从事件里解绑定

如果事件无效或者绑定函数无效，什么都不会发生

如果处理函数被多次绑定，则所有的绑定都会被解除

```lua
eventbus.unbindEvent('eventkey',hanlder)
```

## 事件解绑定

通过unbindAll可以接触指定事件绑定的所有处理函数。

如果事件无效则什么都不会发生

```lua
eventbus.unbindAll()
```

## 重置，解绑全部

通过reset可以取消所有的事件的绑定

```lua
eventbus.reset()
```