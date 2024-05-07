local M={}
M.command={}
M.command.__index = M.command
function M.command:new(id,fn)
    local c = {
        _id=id,
        _fn=fn,
        _intro='',
        _desc='',
    }
    setmetatable(c, self)
    return c
end
function M.command:id()
    return self._id
end
function M.command:withIntro(intro)
    self._intro=intro
    return self
end
function M.command:intro()
    return self._intro
end
function M.command:withDesc(desc)
    self._desc=desc
    return self
end
function M.command:desc()
    if self._desc=="" then
        return self._intro
    else
        return self._desc
    end
end
function M.command:exec(data)
    return self._fn(data)
end
M.commands={}
M.commands.__index = M.commands
function M.commands:new(defaultfn)
    local c={
        _items={},
        _default=defaultfn,
    }
    setmetatable(c, self)
    return c
end
function M.commands:register(id,fn)
    local c=M.command:new(id,fn)
    self._items[id]=c
    return c
end
function M.commands:remove(id)
    self._items[id]=nil
end
function M.commands:list()
    local result={}
    for key, value in pairs(self._items) do
        table.insert(result,value)
    end
    return result
end
function M.commands:getCommand(id)
    return self._items[id]
end
function M.commands:exec(id,data)
    local c=self:getCommand(id)
    if c~=nil then
        return c:exec(data)
    end
    return self._default(id,data)
end
function M.new(defaultfn)
    return M.commands:new(defaultfn)
end
return M