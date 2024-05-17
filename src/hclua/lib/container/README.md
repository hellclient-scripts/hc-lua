# container 容器库

Golang标准库[Container库](https://pkg.go.dev/container)的Lua版本。

目前实现了List和Ring两个容器

* List是一个标准的双向链表，可以在任何位置快速插入数据，能正序或反序进行遍历
* Ring是一个固定打小环形链表，有固定大小，后插入的数据会替代新数据，适合做历史指令等固定尺寸的信息

## List列表
List中的每个元素是一个ListItem对象

### 新建List

```lua
local list=require('container/list.lua')
local li=list.new() -- local li=list.List:new()
```

### List前端插入值
```lua
    local newListItem=li:pushFront('value')
```
返回值为被插入的ListItem

### List后端插入值
```lua
    local newListItem=li:pushBack('value')
```
返回值为被插入的ListItem

### List指定位置前插入值

将指定插入指定的ListItem之前

如果ListItem无效,不会有任何效果
```lua
    local newListItem=li:insertBefore('value',Item)
```
返回值为被插入的ListItem

### List指定位置后插入值

将指定插入指定的ListItem之后

如果ListItem无效,不会有任何效果
```lua
    local newListItem=li:insertAfter('value',Item)
```
返回值为被插入的ListItem

### List将指定元素移动到最前

将指定元素移动到队列的最前方

无返回值

```lua
    li:moveToFront(Item)
```

### List从队列中删除指定元素

无返回值

```lua
    li:remove(Item)
```

### List获取长度

返回List的长度

```lua
    print(li:len())
```

### List获取第一个元素
    如果List为空返回nil
```lua
    local firstItem=li:front()
```

### List获取最后一个元素
    如果List为空返回nil
```lua
    local lastItem=li:back()
```

### List将指定元素移动到最后

将指定元素移动到队列的最后方

无返回值

```lua
    li:moveToBack(Item)
```

### List将指定元素移动另一元素前

将第一个参数中的ListItem移动到第二个参数的元素的ListItem之前

无返回值

```lua
    li:moveBefore(item, target)
```

### List将指定元素移动另一元素后

将第一个参数中的ListItem移动到第二个参数的元素的ListItem之后

无返回值

```lua
    li:moveAfter(item, target)
```

### List将另一个List拼接到最前方

无返回值

```lua
    li:pushFrontList(newList)
```

### List将另一个List拼接到最后方

无返回值

```lua
    li:pushBackList(newList)
```

### ListItem 获取实际值

返回ListItem的实际值

```lua
    local item=li:pushBack('value')
    print (item:value()=='value')
```

### ListItem 获取上一元素

如果是第一个元素则返回空，一般用于遍历
```lua
local item=li:back()
while item~=nil do
    ...
    item=item:prev()
end
```

### ListItem 获取下一元素

如果是最后一个元素则返回空，一般用于遍历
```lua
local item=li:front()
while item~=nil do
    ...
    item=item:next()
end
```


## Ring 环形队列

### Ring 创建环形队列

注意，ring.Ring:new()创建的空环没有大小信息，无法直接使用

```lua
    local ring=require('container/ring.lua')
    local ri:=ring.new()
```

### Ring 获取环形队列长度

注意，这个会循环环形环形队列，一般使用建议直接保存在一个变量里

```lua
    print(ri:len())

```

### Ring 环形队列后滚

向后滚动一个位置，并获取新的环形队列

```lua
ri=ri:next()
```

### Ring 环形队列前滚

向前滚动一个位置，并获取新的环形队列

```lua
ri=ri:prev()
```

### Ring 移动指定位置

参数为移动的位置的整数，正数为向后滚，负数为向前滚

返回值为新的环形队列

```lua
ri=ri:move(10)
```

### Ring 设置当前值

设置当前位置环形队列的值

返回值为当前环形队列

```lua
    ri=ri:next():withValue('newValue')
```

### Ring获取当前位置的值

当前位置没有设置过值的话，会返回nil

```lua
    print(ri:value())
```

## Ring 遍历应用函数

从当前位置开始，想后(next)方向遍历以全，调用应用函数。

应用函数的的参数为对应位置的值

未设置部分会传入空值

```lua
ri:apply(function(value)
    if value~=nil then
        print(value)
    end
end)
```

### Ring 拼接另一个环形队列

将新的环形队列插入当前环形队列的当前位置和下一位置(next)之间。

会改变环的长度

```lua
    ri:link(newRing)
```

## Ring 切除元素

切除从当前元素开始的第一个数量的元素。

第一个参数必须为正数,而且不超过当前环长度-1

```lua
    ri:unlink(1)
```