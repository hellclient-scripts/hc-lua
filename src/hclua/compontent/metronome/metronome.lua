return function(runtime)
    local list = runtime:require('lib/container/list.lua')
    local M = {}

    M.Metronome = {}
    M.Metronome.__index = M.Metronome

    -- 默认时钟,测试时可替换为测试时钟
    function M.DefaultTimer()
        return os.time()
    end

    -- 默认拍子数
    function M.DefaultBeats()
        return 6
    end

    -- 默认节奏
    function M.DefaultTick()
        return 0.6
    end

    -- 默认发送函数。正常使用必须替换。
    function M.DefaultSender(metronome, cmd)
    end

    -- 默认解码器。直接原文返回。
    function M.DefaultDecoder(metronome, data)
        return data
    end

    -- 默认转换函数。直接返回原指令
    function M.DefaultConverter(metronome, data)
        return data
    end

    -- 创建新的节拍器
    function M.Metronome:new()
        local m = {
            _beats = 0,
            _tick = 0,
            _timer = M.DefaultTimer,
            _queue = list:new(),
            _sent = list:new(),
            _paused = false,
            _resumeNext = false,
            _sender = self.DefaultSender,
            _decoder = M.DefaultDecoder,
            _converter = M.DefaultConverter,
            _pipe = nil,
            _last = {},
            params = {}
        }
        setmetatable(m, self)
        return m
    end

    function M.Metronome:_getTime()
        return self:_timer()
    end

    -- 设置转发的管道
    -- 传入nil则取消转发
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:withPipe(p)
        self._pipe = p
        return self
    end

    -- 设置解码器
    -- 如果要设置自定义指令，需要设置解码器
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:withDecoder(d)
        self._decoder = d
        return self
    end

    -- 设置解转换器
    -- 转换器用于在队列之后，发送时对指令进行转换。
    -- 一般用于在限制频率时，将多条指令当作一条指令进行计算。
    -- 也可以用来触发发送指令时要处理的代码
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:withConverter(d)
        self._converter = d
        return self
    end

    -- 设置计时器
    -- 计时器返回的值是单位时间，单位应与tick单位一致
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:withTimer(t)
        self._timer = t;
        return self
    end

    -- 设置发送函数
    -- 发送函数应该对接客户端
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:withSender(t)
        self._sender = t;
        return self
    end

    -- 返回节拍器的节奏
    -- 节奏应为对timer的应单位时间
    -- 超过节奏值的历史记录将不阻塞节拍器
    -- 如果设置小于等于0,默认节奏将被返回
    function M.Metronome:getTick()
        if self._tick <= 0 then
            return M.DefaultTick()
        end
        return self._tick
    end

    -- 设置节拍器的节奏
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:withTick(tick)
        self._tick = tick
        return self
    end

    -- 获取节拍器的拍子数
    -- 拍子数指一个节奏内最多发出多少指令
    -- 返回节拍器自身，方便链式调用
    -- 如果设置小于等于0,默认拍子数将被返回
    function M.Metronome:getBeats()
        if self._beats <= 0 then
            return M.DefaultBeats()
        end
        return self._beats
    end

    -- 设置节拍器的拍子数
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:withBeats(beats)
        self._beats = beats
        return self
    end

    -- 返回节拍器队列中的指令
    -- 返回值为数组，每个值代表一个指令组
    -- 如果plain参数为true,所有指令将被不分组的返回在一个数组里。方便打印查看
    -- 指令组内的值是有顺序的字符串或函数
    -- 多个指令指令组中的函数也会返回，但不会被发送
    function M.Metronome:queue(plain)
        local q = {}
        local e = self._queue:front()
        while e ~= nil do
            if plain then
                for index, value in ipairs(e:value()) do
                    table.insert(q, value)
                end
            else
                table.insert(q, e:value())
            end
            e = e:next()
        end
        return q
    end

    -- 填充节拍器，之后的节奏时间内队列会被阻塞，不发送指令
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:full()
        local t = self:_getTime()
        local b = self:getBeats()
        self.sent = list.new()
        local i = 0
        while i < b do
            self._sent:pushBack(t)
            i = i + 1
        end
        return self
    end

    -- 填充节奏，当前节奏视作节拍发送已满，直到现有节拍过期才能继续发送
    -- 与full的区别在于，对当前节拍内已经有发送过指令处理不同
    -- 当前发送过的指令会使得节拍器提早接触阻塞
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:fullTick()
        local t = self:_getTime()
        local b = self:getBeats()
        local i = self._sent:len()
        while i < b do
            self._sent:pushBack(t)
            i = i + 1
        end
        return self
    end

    -- 节拍器等待指定时间
    -- 传入的参数为单位时间，默认为0，节拍器会阻塞对应的时间
    -- 注意，如果传入的等待时间太小，已经发送的指令还为解除阻塞，则由本身逻辑确定还能发出多少拍子
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:wait(offset)
        if offset == nil then
            offset = 0
        end
        local t = self:_getTime() - self:getTick() + offset
        local b = self:getBeats()
        local i = 0
        while i < b do
            self._sent:pushBack(t)
            i = i + 1
        end
        return self
    end

    -- 部分填充，填充指定节拍，用于通过其他方式绕过节拍控制后对节奏做相应调整
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:hold(beats)
        if (beats <= 0) then
            return self
        end
        local t = self:_getTime()
        self.sent = list.new()
        local i = 0
        while i < beats do
            self._sent:pushBack(t)
            i = i + 1
        end
        return self
    end

    -- 暂停节拍器
    -- 暂停后阻塞队列
    -- 不影响send方法
    -- 暂停中还能暂停，无实际作用
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:pause()
        self._paused = true
        return self
    end

    -- 返回是否暂停
    -- 暂停状态返回true,工作状态返回false
    -- 使用暂停不会影响resumeNext状态
    function M.Metronome:paused()
        return self._paused
    end

    -- 恢复节拍器
    -- 回复后取消暂停状态
    -- 工作状态中也能使用该指令，无实际作用
    -- 使用resume后，resumeNext的状态也会被重置
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:resume()
        self._paused = false
        self._resumeNext = false
        self:play()
        return self
    end

    -- 恢复并发送下一个指令
    -- 暂停状态下使用该指令会允许下一个指令组被发送，但不影响暂停状态
    -- 函数调用不记数,会执行函数并继续执行下一个指令组
    -- 如果需要在函数调用里中止resumeNext,需要手动调用stopResumeNext方法
    -- 工作状态中也能使用该指令，无实际作用
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:resumeNext()
        if self._paused then
            self._resumeNext = true
        end
        self:play()
        return self
    end

    -- 取消resumeNext状态
    -- 用于resumeNext函数里停止下一个指令的执行
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:stopResumeNext()
        self._resumeNext = false
        return self
    end

    function M.Metronome:_clean()
        local t = self:_getTime()
        local e = self._sent:front()
        while e ~= nil do
            local next = e:next()
            if (e:value() == nil or t - e:value() > self:getTick()) then
                self._sent:remove(e)
            end
            e = next
        end
    end

    function M.Metronome:_exec(cmds)
        if #cmds == 1 then
            if type(cmds[1]) == 'function' then
                cmds[1](self)
                return
            end
        end
        cmds = self._converter(self, cmds)
        self._resumeNext = false
        self._last = cmds
        local t = self:_getTime()
        if self._pipe ~= nil then
            local grouped = (#cmds > 1)
            for index, value in ipairs(cmds) do
                if type(value) ~= 'function' then
                    self._sent:pushBack(t)
                end
            end
            self._pipe:push(cmds, grouped)
            return
        end
        for index, value in ipairs(cmds) do
            if type(value) ~= 'function' then
                self._sent:pushBack(t)
                self:_sender(value)
            end
        end
    end

    -- 节拍器的自检函数。
    -- 清理发送记录，并尝试发送队列中的指令
    -- 正常使用需要与客户端的timer挂钩
    function M.Metronome:play()
        if self._paused and not self._resumeNext then
            return
        end
        self:_clean()
        local b = self:getBeats()
        while self._queue:len() > 0 and self._sent:len() < b do
            local e = self._queue:front()
            local cmds = e:value()
            if b - self._sent:len() < #cmds then
                -- 避免cmds长于beats时永远不发送
                if self._sent:len() ~= 0 then
                    return
                end
            end
            self._queue:remove(e)
            self:_exec(cmds)
            if self._paused and not self._resumeNext then
                return
            end
        end
    end

    -- 直接发送指令
    -- 参数cmd为字符串，如传入函数不做任何操作
    -- 不受节拍器暂停和阻塞影响
    -- 会留下发送记录
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:send(cmd)
        if type(cmd) == 'function' then
            return
        end
        cmds = self._converter(self, { cmd })
        local t = self:_getTime()
        for index, value in ipairs(cmds) do
            self._sent:pushBack(t)
            if self._pipe ~= nil then
                self._pipe:send(value)
            else
                self:_sender(value)
            end            
        end
        return self
    end

    function M.Metronome:_append(cmds, grouped, insert)
        for index, value in ipairs(cmds) do
            cmds[index] = self._decoder(self, value)
        end
        if (grouped) then
            if insert then
                self._queue:pushFront(cmds)
            else
                self._queue:pushBack(cmds)
            end
        else
            local newcmds = list.new()
            for index, value in ipairs(cmds) do
                newcmds:pushBack({ value })
            end
            if insert then
                self._queue:pushFrontList(newcmds)
            else
                self._queue:pushBackList(newcmds)
            end
        end
    end

    -- 重置节拍器发送记录
    -- 注意，如果队列中还有未发送指令，会进行正常发送
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:reset()
        self._sent = list.new()
        self:play()
        return self
    end

    -- 清除未发送的队列
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:discard()
        self._queue = list.new()
        return self
    end

    -- 返回当前时间还能发送命令的数量
    -- 返回值不会小于0
    function M.Metronome:space()
        self:_clean()
        local space = self:getBeats() - self._sent:len()
        if (space < 0) then
            space = 0
        end
        return space
    end

    -- 将指令推入队列后方
    -- cmds为字符串或函数的数组
    -- 函数会接受到节拍器作为第一个参数执行
    -- grouped代表是否是否按组发送
    -- 按组发送时，如果指令长度超过1,指令中的函数不会被执行。
    -- 按组发送时，必须在同一个节奏发出。如果当前节奏不够整个组输出，会阻塞队列
    -- 如果指令比节拍数还长，会在空节奏里，将全部指令输出，并阻塞队列
    -- 返回节拍器自身，方便链式调用
    function M.Metronome:push(cmds, grouped)
        self:_append(cmds, grouped, false)
        self:play()
        return self
    end

    -- 将指令插入队列最前方，队列接触阻塞时将优先发送
    -- 其他同push方法
    function M.Metronome:insert(cmds, grouped)
        self:_append(cmds, grouped, true)
        self:play()
        return self
    end

    -- 创建节拍器的别名
    function M.new()
        return M.Metronome:new()
    end

    -- 返回最后一个发送指令组
    function M.Metronome:last()
        return self._last
    end

    -- 将最后一个发送的指令组压入队伍最前方并尝试resumeNext
    -- 由于resumeNext也需要进行缓存处理，连续的resend可能导致只有第一个resend的指令被发送,会导致堆记多个指令在队列前方
    -- 返回节拍器自身，方便链式调sss用
    function M.Metronome:resend()
        if self._last == nil then
            return
        end
        self:insert(self._last, true)
        self:resumeNext()
        return self
    end

    return M
end
