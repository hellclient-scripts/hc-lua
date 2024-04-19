local M = {}

M.Ring = {}
M.Ring.__index = M.Ring

function M.Ring:new()
    local r = {
        _next = nil,
        _prev = nil,
        _value = nil,
    }
    setmetatable(r, self)
    return r
end

function M.Ring:_init()
    self._next = self
    self._prev = self
    return self
end

function M.Ring:next()
    if self._next == nil then
        return self:_init()
    end
    return self._next
end

function M.Ring:prev()
    if self._next == nil then
        return self:_init()
    end
    return self._prev
end

function M.Ring:value()
    return self._value
end

function M.Ring:withValue(v)
    self._value = v
    return self
end

function M.Ring:move(n)
    if self._next == nil then
        return self:_init()
    end
    local r = self
    if n < 0 then
        while n < 0 do
            r = r:prev()
            n = n + 1
        end
    elseif n > 0 then
        while n > 0 do
            r = r:next()
            n = n - 1
        end
    end
    return r
end

function M.Ring:link(r)
    local n = self:next()
    if (r ~= nil) then
        local p = r:prev()
        self._next = r
        r._prev = self
        n._prev = p
        p._next = n
    end
    return n
end

function M.Ring:unlink(n)
    if n <= 0 then
        return nil
    end
    return self:link(self:move(n + 1))
end

function M.Ring:len()
    local n = 0
    if (self ~= nil) then
        n = 1
        local p = self:next()
        while p ~= self do
            n = n + 1
            p = p:next()
        end
    end
    return n
end

function M.Ring:apply(fn)
    if (self ~= nil) then
        fn(self:value())
        local p = self:next()
        while p ~= self do
            fn(p:value())
            p = p:next()
        end
    end
end

function M.new(n)
    if (n <= 0) then
        return nil
    end
    local r = M.Ring:new()
    local p = r
    local i = 1
    while i < n do
        local newp = M.Ring:new()
        newp._prev = p
        p._next = newp
        p = newp
        i = i + 1
    end
    p._next = r
    r._prev = p
    return r
end

return M
