return function(runtime)
    local list = runtime:require('lib/container/list.lua')
    local M = {}

    M.Metronome = {}
    M.Metronome.__index = M.Metronome

    -- 默认时钟,测试时可替换为测试时钟
    function M.DefaultTimer()
        return os.clock
    end

    -- 默认每节拍指令数,未设置或者设置小与等于0时使用该值。
    function M.DefaultBeats()
        return 10
    end

    -- 默认每节拍指令数,未设置或者设置小与等于0时使用该值。
    function M.DefaultTick()
        return 500
    end

    -- 默认发送函数。正常使用必须替换。
    function M.DefaultSender(metronome, cmd)
    end

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
            _pipe = nil
        }
        setmetatable(m, self)
        return m
    end

    function M.Metronome:getTime()
        return self:_timer()
    end

    function M.Metronome:WithPipe(p)
        self._pipe = p
        return self
    end

    function M.Metronome:WithTimer(t)
        self._timer = t;
        return self
    end

    function M.Metronome:WithSender(t)
        self._sender = t;
        return self
    end

    function M.Metronome:getTick()
        if self._tick <= 0 then
            return M.DefaultTick()
        end
        return self._tick
    end

    function M.Metronome:withTick(tick)
        self._tick = tick
        return self
    end

    function M.Metronome:getBeats()
        if self._beats <= 0 then
            return M.DefaultBeats()
        end
        return self._beats
    end

    function M.Metronome:withBeats(beats)
        self._beats = beats
        return self
    end

    function M.Metronome:queue()
        local q = {}
        local e = self._queue:front()
        while e ~= nil do
            table.insert(q, e:value())
            e = e:next()
        end
        return q
    end

    function M.Metronome:full()
        local t = self:getTime()
        local b = self:getBeats()
        self.sent = list.new()
        local i = 0
        while i < b do
            self._sent:pushBack(t)
            i = i + 1
        end
    end

    function M.Metronome:fullTick()
        local t = self:getTime()
        local b = self:getBeats()
        local i = self._sent:len()
        while i < b do
            self._sent:pushBack(t)
            i = i + 1
        end
    end

    function M.Metronome:wait(offset)
        if offset == nil then
            offset = 0
        end
        local t = self:getTime() - self:getTick() + offset
        local b = self:getBeats()
        local i = 0
        while i < b do
            self._sent:pushBack(t)
            i = i + 1
        end
    end

    function M.Metronome:pause()
        self._paused = true
    end

    function M.Metronome:paused()
        return self._paused
    end

    function M.Metronome:resume()
        self._paused = false
        self:play()
    end

    function M.Metronome:resumeNext()
        self._resumeNext = true
        self:play()
    end

    function M.Metronome:clean()
        local t = self:getTime()
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
        if self._pipe ~= nil then
            local grouped = (#cmds > 1)
            self._pipe.push(cmds, grouped)
            return
        end
        for index, value in ipairs(cmds) do
            if type(cmds) ~= 'function' then
                local t = self:getTime()
                self._sent:pushBack(t)
                self:_sender(value)
            end
        end
    end

    function M.Metronome:play()
        if self._paused and not self._resumeNext then
            return
        end
        self:clean()
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
            self._resumeNext = false
            self:_exec(cmds)
            if self._paused and not self._resumeNext then
                return
            end
        end
    end

    function M.Metronome:send(cmd)
        if type(cmd) == 'function' then
            return
        end
        if self._pipe ~= nil then
            self._pipe:send(cmd)
            return
        end
        local t = self:getTime()
        self._sent:pushBack(t)
        self:_sender(cmd)
    end

    function M.Metronome:_append(cmds, grouped, insert)
        if (grouped) then
            if insert then
                self._queue:pushFront(cmds)
            else
                self._queue:pushBack(cmds)
            end
        else
            local newcmds=list.new()
            for index, value in ipairs(cmds) do
                newcmds:pushBack({value})
            end
            if insert then
                self._queue:pushFrontList(newcmds)
            else
                self._queue:pushBackList(newcmds)
            end

        end
    end

    function M.Metronome:reset()
        self._sent = list.new()
        self:play()
    end

    function M.Metronome:discard()
        self._queue = list.new()
    end

    function M.Metronome:space()
        self:clean()
        local space = self:getBeats() - self._sent:len()
        if (space < 0) then
            space = 0
        end
        return space
    end

    function M.Metronome:push(cmds, grouped)
        self:_append(cmds, grouped,false)
        self:play()
    end

    function M.Metronome:insert(cmds, grouped)
        self:_append(cmds, grouped,true)
        self:play()
    end

    function M.new()
        return M.Metronome:new()
    end

    return M
end
