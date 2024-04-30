return function(runtime)
    local ring = runtime:require('lib/container/ring.lua')
    local list = runtime:require('lib/container/list.lua')
    local eventbus = runtime:require('lib/eventbus/eventbus.lua')

    local M = {}
    M.History = {}
    M.History.__index = M.History
    function M.History:new(length)
        local h = {
            _length = length,
            _ringlength = length,
            _ring = ring.new(length),
            _eventbus = eventbus.new(),
            params = {},
        }
        setmetatable(h, self)
        return h
    end

    function M.History:getLength()
        return self._length
    end

    function M.History:withLength(length)
        self._length = length
        return self
    end

    function M.History:onLine(line)
        self._ring = self._ring:next():withValue(line)
    end

    function M.History:flush()
        self._ring = ring.new(self._length)
        self._ringlength = self._length
    end

    function M.History:current()
        return self._ring:value()
    end

    function M.History:getLines(length, offset)
        if offset == nil then
            offset = 0
        end
        if offset < 0 or offset >= self._length then
            return nil
        end
        if length > self._ringlength - offset then
            length = self._ringlength - offset
        end
        local r = self._ring
        local i = 0
        while i < offset do
            r = r:prev()
            i = i + 1
        end

        local result = {}
        local count = 0
        while count < length do
            local value = r:value()
            if (value == nil) then
                break
            end
            r = r:prev()
            table.insert(result, value)
            count = count + 1
        end
        return result
    end

    function M.History:createRecorder()
        return M.Recorder:new(self)
    end

    function M.new(length)
        return M.History:new(length)
    end

    M.Recorder = {}
    M.Recorder.__index = M.Recorder
    function M.Recorder:new(history)
        if history == nil then
            return nil
        end

        local r = {
            _cap = 0,
            _lines = list.new(),
            _history = history,
            _onFull = nil
        }
        r._binder = function(data)
            r:onLine(data)
        end
        setmetatable(r, self)
        history._eventbus:bindEvent('line', r._binder)
        return r
    end

    function M.Recorder:onLine(line)
        if self._lines.length < self._cap then
            self._lines.pushBack(line)
            if self._lines.length == self._cap then
                if self._onFull ~= nil then
                    self._onFull(self)
                    self._onFull=nil
                end
            end
        end
    end

    function M.Recorder:detach()
        self._history._eventbus:unbindEvent('line', self._binder)
    end

    function M.Recorder:start(cap, onfull)
        if cap == nil then
            cap = 1
        end
        self._onFull = onfull
        self._lines = list.new()
    end

    function M.Recorder:cap()
        return self.cap
    end

    function M.Recorder:length()
        return self._lines:length()
    end
    function M.Recorder:stop()
        self._cap=0
        self._onFull=nil
    end
    function M.Recorder:running()
        return self.cap<=self._lines.length
    end
    function M.Recorder:getLines()
        local result = {}
        local e = self._lines.front()
        while e ~= nil do
            table.insert(result, e:value())
            e = e:next()
        end
        return result
    end

    return M
end
