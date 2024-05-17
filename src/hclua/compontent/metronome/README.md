# metronome 节拍限流器模块

Metornome是通过控制已发送记录，进行发送限流的限流模块。基本功能是取代各大客户端的speedwalk模块，避免过快发送指令。同时，节拍器可以通过pause,resume,resumeNext,resend,full,fulltick,wait等控制指令进行精细的节奏控制，能满足基本的输出队列的使用需求。节拍器也加入了Decoder和Converter对指令在分送前和后进行解码的功能，使得能方便的进行多个队列的管道转发。

## metronome的可编程部分

### 流程控制
* pasuse/resume:节拍器可以通过pause和resume进行基本的暂停控制。
* resumeNext:在暂停后节拍器就是一个标准的指令队列，所以加入了resumeNext，步进式发送指令，可以手动响应触发进行执行标准的单布指令发送。
* resend: 在发送指令时加入了最后一个指令的记录，因此可以实现在单步发送时，能失败重发最后的指令。

### 时间控制
标准情况下，节拍器是通过高频率检查已发送记录，清理过了限制期的发送记录，根据还剩余多少发送空间来极限输出指令。
* full 通过填满整个已发送记录空间，强制一个完整时间周期不发送指令。
* fulltick 将剩余可发送空间填满，强制下一个周期开始发送指令。
* wait 通过把未来的指定时间段的记录也填充满，使得指定时间内不再节拍器不在发送指令，模拟wait功能

### 函数指令

metornome可以推文字指令或者函数指令

函数指令的特点是：

* 在队列执中派对到它时才执行，会传入metornome对象，能对流程本身进行控制
* 默认不占用已发送空间，可以通过hold函数占用响应函数，也可以用insert方法在队列最前方插入指令
* 可以调用metornome的send方法绕过已发送限制
* 在按组发送时，函数指令会被忽略，只有单个发送时才有效

### 指令转发

可以将多个节拍器的内容转发到一个主节拍器上。
比如可以为战斗，移动，遍历等建立不同的节拍器，分别以不同的频率进行限流/#wait/手动空制，不影响整体发送。

比如

* 主节拍器根据心跳和指令限制限流
* 战斗以秒为节拍发送，同时限制不要占据全部的节拍（比主节拍器限制略小）
* 移动限制一个很低的节奏，避免移动速度过快被mud限制。或者保证在每个房间呆够一定时间。
* 遍历可以pause后，手动控制resumeNext,单布触发

### 指令转换

指令转换分为解码(Decode)和转换(Convert)

Decoder一般用于将指令转换为函数，比如实现#wait功能。它的特点是
* 一个待Decode的指令，在计算占位前就进行解码，正常计算已发送记录。
* 不作用于send函数，重发不会重新Decode
* 只能做指令的一对一转换

Converter一般用于管道转发指令时，比如将计算一次n&&e&&w 的指令拆换为3个指令{n,e,w}。它的特点是
* 作用时间在计算占位之后，不影响占位
* 作用于send函数，重发会重新convert
* 做指令组和指令组的转换，可以1转多
* 时间点在Decode之后，可以用作触发事件，更新最新的队列内容的显示。

## metronome接口

metromome有两个核心参数，tick和beats。

含义为在最近tick时间内，发送不超过beats的指令。

一般建议tick比心跳的一般略长，beats取心跳指令限制的一半。

metronome需要有一个高速timer定期调用play方法进行发送监测。

还需要一个timer,能感知两次timer之间过去的时间。

### metronome 创建节拍器

```lua
local metronome=runtime:requireModule('compontent/metronome/metronome.lua')
local me=metronome.new() -- local me=metronome.Metronome:new()
```
### metronome 节拍器更新函数

使用时需要定期调用本函数更新节拍器

```lua
metronome:play()
```

### metronome 设置timer

设置一个能统计两次play之间过去多少时间的函数为timer

返回节拍器本身方便链式调用

```lua
    me:withTimer(os.clock)
```

### metronome 返回时间

调用timer返回参考时间,应该为数字
```lua
    print(me:getTime())
```

### metronome 设置tick

设置已发送记录过期的周期,单位应该与getTime返回的单位一致

返回节拍器本身方便链式调用

```lua
    me:withTick(0.5)
```

### metronome 返回tick

返回节拍器的节奏

节奏应为对timer的应单位时间

超过节奏值的历史记录将不阻塞节拍器

如果设置小于等于0,默认节奏将被返回

```lua
    print(me:getTick())
```

### metronome 设置beats

beats节拍指如果tick内有超过beats个已发送记录，就阻塞发送

返回节拍器自身，方便链式调用

```lua
    me:withBeats(5)
```

### metronome 返回beats

获取节拍器的拍子数

拍子数指一个节奏内最多发出多少指令

返回节拍器自身，方便链式调用

如果设置小于等于0,默认拍子数将被返回

```lua
    print(me:getBeats())
```

### metronome 设置发送函数

发送函数应该对接客户端

返回节拍器自身，方便链式调用

```lua
me:withSender(function(metronome,command)
    print(command)
end)
```
### metronome 设置解码器

如果要设置自定义指令，需要设置解码器

返回节拍器自身，方便链式调用

```lua
me:withDecoder(function(metronome, cmd)
    if cmd=='#wait' return function()
        metronome.wait(10)
    end
    return cmd
end)
```
### metronome 设置转换器

转换器用于在队列之后，发送时对指令进行转换。

一般用于在限制频率时，将多条指令当作一条指令进行计算。

也可以用来触发发送指令时要处理的代码

返回节拍器自身，方便链式调用


```lua
me:withConverter(function(metronome,cmds)
    raiseEvent('metronome updated')
    for index, value in ipairs(cmds) do
        if value=='#cmd' then
            cmds[index]='#cmd2'
        end
    end
    return cmds
end)
```

### metronome 设置管道转发

设置转发的管道

传入nil则取消转发

返回节拍器自身，方便链式调用

```lua
local roomme:=metronome.new():withTick(4000):withBeats(1):withPipe(me)
```

### metronome 返回队列内容

返回节拍器队列中的指令

返回值为数组，每个值代表一个指令组

如果plain参数为true,所有指令将被不分组的返回在一个数组里。方便打印查看

指令组内的值是有顺序的字符串或函数

多个指令指令组中的函数也会返回，但不会被发送

```lua
print(table.concat(me:queue(true),';'))

local groups=me:queue()
for index, cmd in ipairs(cmds) do
    print(table.concat(cmd,';'))
end
```

### metronome 推送指令

将指令推入队列后方

cmds为字符串或函数的数组

函数会接受到节拍器作为第一个参数执行

grouped代表是否是否按组发送

按组发送时，如果指令长度超过1,指令中的函数不会被执行。

按组发送时，必须在同一个节奏发出。如果当前节奏不够整个组输出，会阻塞队列

如果指令比节拍数还长，会在空节奏里，将全部指令输出，并阻塞队列

返回节拍器自身，方便链式调用

```lua
    me:push({'a','b','c'},true)
```

### metronome 插入指令

将指令插入队列最前方，队列解除阻塞时将优先发送

其他同push方法

```lua
    me:insert({'a','b','c'},true)
```

### metronome 直接发送

直接发送指令

参数cmd为字符串，如传入函数不做任何操作

不受节拍器暂停和阻塞影响

会留下发送记录

返回节拍器自身，方便链式调用

```lua
me:send('look')
```

### metronome 获取最后发送指令

返回最后一个发送指令组

不包括send指令发送的内容
```lua
print(table.concat(me:last(),';'))
```

### metronome 重试发送

将最后一个发送的指令组压入队伍最前方并尝试resumeNext

由于resumeNext也需要进行缓存处理，连续的resend可能导致只有第一个resend的指令被发送,会导致堆记多个指令在队列前方

不包括send指令发送的内容

返回节拍器自身，方便链式调用

```lua
me:resend()
```

### metronome 暂停节拍器

暂停节拍器

暂停后阻塞队列

不影响send方法

暂停中还能暂停，无实际作用

返回节拍器自身，方便链式调用
```lua
me:pause()
```

### metronome 恢复节拍器

恢复后取消暂停状态

工作状态中也能使用该指令，无实际作用

使用resume后，resumeNext的状态也会被重置

返回节拍器自身，方便链式调用
```lua
me:resume()
```

### metronome 获取暂停状态

返回是否暂停

暂停状态返回true,工作状态返回false

```lua
print(me:paused()==true)
```

### metronome 单步发送

恢复并发送下一个指令

暂停状态下使用该指令会允许下一个指令组被发送，但不影响暂停状态

函数调用不记数,会执行函数并继续执行下一个指令组

如果需要在函数调用里中止resumeNext,需要手动调用stopResumeNext方法

工作状态中也能使用该指令，无实际作用

返回节拍器自身，方便链式调用

```lua
me:resumeNext()
```

### metronome 取消单步发送

取消resumeNext状态

用于resumeNext函数里停止下一个指令的执行

返回节拍器自身，方便链式调用

```lua
me:stopResumeNext()
```

### metronome 填充节拍器

填充节拍器，之后的节奏时间内队列会被阻塞，不发送指令

返回节拍器自身，方便链式调用

```lua
me:full()
```

### metronome 填充节奏

填充节奏，当前节奏视作节拍发送已满，直到现有节拍过期才能继续发送

与full的区别在于，对当前节拍内已经有发送过指令处理不同

当前发送过的指令会使得节拍器提早解除阻塞

返回节拍器自身，方便链式调用

```lua
me:fullTick()
```

### metronome 等待时间

传入的参数为单位时间，默认为0，节拍器会阻塞对应的时间

注意，如果传入的等待时间太小，已经发送的指令还未解除阻塞，则由本身逻辑确定还能发出多少拍子

返回节拍器自身，方便链式调用

```lua
me:wait(3000)
```

### metronome 部分填充节奏

部分填充，填充指定节拍，用于通过其他方式绕过节拍控制后对节奏做相应调整

返回节拍器自身，方便链式调用

```lua
me:hold(3)
```

### metronome 重置发送记录

重置节拍器发送记录

注意，如果队列中还有未发送指令，会进行正常发送

如果需要彻底重置节拍器，应该先discard,再reset

返回节拍器自身，方便链式调用

```lua
metronome:reset()
```

### metronome 清除未发送的队列

清除未发送的队列

返回节拍器自身，方便链式调用

```lua
metronome:discard()
```
### metronome 获取可发送余量

返回当前时间还能发送命令的数量

返回值不会小于0

```lua
print(me:space()>0)
```


