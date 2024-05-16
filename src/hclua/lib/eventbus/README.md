# 事件总线
该库用于简单的事件绑定和触发

## 创建总线

每一个总线有一套独立的事件和转发机制

注册多个总线的话可以同时使用多套事件

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
eventbus:raiseEvent('eventkey',eventdata)
```

**特别注意:不保证事件触发时的前后处理关系。**

## 处理函数解绑定

通过unbindEvent可以将指定的处理函数从事件里解绑定

如果事件无效或者绑定函数无效，什么都不会发生

如果处理函数被多次绑定，则所有的绑定都会被解除

```lua
eventbus:unbindEvent('eventkey',hanlder)
```

## 事件解绑定

通过unbindAll可以接触指定事件绑定的所有处理函数。

如果事件无效则什么都不会发生

```lua
eventbus:unbindAll('eventkey')
```

## 绑定转发

一般来说，不建议由于事件机制的易失控性，完全通过管线进行触发一般只建议在底层驱动使用，在业务层推荐将事件转发到唯一的响应/处理系统，确认作用域。

转发就是将所有事件和上下文转发给统一的处理函数。

注意，转发的处理在所有已经绑定的处理函数之后，同时按转发绑定的顺序进行执行。

转发的处理函数为
```lua
function forwardingHandler(eventkey,context){
      ...
}
```

绑定转发的代码为
```lua
      eventbus:bindForward(handler)
```

## 解除转发

将指定的转发处理函数出绑定队列里移除

```lua
      eventbus:unbindForward(handler)
```

## 重置，解绑全部和转发

通过reset可以取消所有的事件的绑定以及转发的绑定

```lua
eventbus:reset()
```