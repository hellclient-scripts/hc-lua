local M = {}
-- list对象。参考golang的list实现

M.ListItem = {}
M.ListItem.__index = M.ListItem
function M.ListItem:new()
    local item = {
        _prev = nil,
        _next = nil,
        value = nil,
        _list = nil
    }
    setmetatable(item, self)
    return item
end

function M.ListItem:next()
    local p = self._next
    if self._list ~= nil and p ~= self._list._root then
        return p
    end
    return nil
end

function M.ListItem:prev()
    local p = self._prev
    if self._list ~= nil and p ~= self._list._root then
        return p
    end
    return nil
end

function M.ListItem:value()
    return self._value
end

M.List = {}
M.List.__index = M.List
function M.List:init()
    self._root = M.ListItem:new()
    self._root._prev = self._root
    self._root._next = self._root
    self._len = 0
end

function M.List:new()
    local list = {
    }
    setmetatable(list, self)
    list:init()
    return list
end

function M.List:len()
    return self._len
end

function M.List:front()
    if self._len == 0 then
        return nil
    end
    return self._root._next
end

function M.List:back()
    if self._len == 0 then
        return nil
    end
    return self._root._prev
end

function M.List:_lazyinit()
    if self._root._next == nil then
        self.Init()
    end
end

function M.List:_insert(e, at)
    e._prev = at
    e._next = at._next
    e._prev._next = e
    e._next._prev = e
    e._list = self
    self._len = self._len + 1
    return e
end

function M.List:_insertValue(v, at)
    local e = M.ListItem:new()
    e._value = v
    return self:_insert(e, at)
end

function M.List:_remove(e)
    e._prev._next = e._next
    e._next._prev = e._prev
    e._next = nil
    e._prev = nil
    e._list = nil
    self._len = self._len - 1
end

function M.List:_move(e, at)
    if e == at then
        return
    end
    e._prev._next = e._next
    e._next._prev = e._prev
    e._prev = at
    e._next = at._next
    e._prev._next = e
    e._next._prev = e
end

function M.List:remove(e)
    if e._list == self then
        self:_remove(e)
    end
    return e._value
end

function M.List:pushFront(value)
    self:_lazyinit()
    return self:_insertValue(value, self._root)
end

function M.List:pushBack(value)
    self:_lazyinit()
    return self:_insertValue(value, self._root._prev)
end

function M.List:insertBefore(value, mark)
    if mark._list ~= self then
        return nil
    end
    return self:_insertValue(value, mark._prev)
end

function M.List:insertAfter(value, mark)
    if mark._list ~= self then
        return nil
    end
    return self:_insertValue(value, mark)
end

function M.List:moveToFront(element)
    if element._list ~= self or self._root._next == element then
        return
    end
    self:_move(element, self._root)
end

function M.List:moveToBack(element)
    if element._list ~= self or self._root._prev == element then
        return
    end
    self:_move(element, self._root._prev)
end

function M.List:moveBefore(element, mark)
    if element._list ~= self or element == mark or mark._list ~= self then
        return
    end
    self:_move(element, mark._prev)
end

function M.List:moveAfter(element, mark)
    if element._list ~= self or element == mark or mark._list ~= self then
        return
    end
    self:_move(element, mark)
end

function M.List:pushBackList(other)
    self:_lazyinit()
    local i = other:len()
    local e = other:front()
    while i > 0 do
        i = i - 1
        self:_insertValue(e:value(), self._root._prev)
        e = e:next()
    end
end

function M.List:pushFrontList(other)
    self:_lazyinit()
    local i = other:len()
    local e = other:back()
    while i > 0 do
        i = i - 1
        self:_insertValue(e:value(), self._root)
        e = e:prev()
    end
end

function M.new()
    return M.List:new()
end

return M
