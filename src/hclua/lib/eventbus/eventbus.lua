local M = {}
M.EventBus = {}
M.EventBus.__index = M.EventBus
-- 创建事件总线函数
function M.EventBus:new()
    local e = {
        _handlers = {},
        _forward = {},
    }
    setmetatable(e, self)
    return e
end

-- 绑定事件
-- 事件可以重复绑定
-- 不应该依赖绑定顺序
function M.EventBus:bindEvent(event, handler)
    if self._handlers[event] == nil then
        self._handlers[event] = {}
    end
    table.insert(self._handlers[event], (handler))
end

-- 解绑事件处理函数
-- 解绑执行事件下所有绑定过的指定事件处理器
-- event可以不存在
function M.EventBus:unbindEvent(event, handler)
    if self._handlers[event] == nil then
        return
    end
    local result = {}
    for i, v in ipairs(self._handlers[event]) do
        if v ~= handler then
            table.insert(result, v)
        end
    end
    if (#result == 0) then
        self._handlers[event] = nil
    else
        self._handlers[event] = result
    end
end

-- 解绑某个事件所有的处理函数
-- event可以不存在
function M.EventBus:unbindAll(event)
    self._handlers[event] = nil
end

-- 重置，放弃所有绑定和转发
function M.EventBus:reset()
    self._handlers = {}
    self._forward = {}
end

-- 触发事件，并将传入的context上下文传递给每一个处理函数
-- 在bindEvent的handler处理完后，会将事件名和context按注册顺序传给每一个转发函数
-- event可以不存在
function M.EventBus:raiseEvent(event, context)
    if self._handlers[event] ~= nil then
        for i, v in ipairs(self._handlers[event]) do
            v(context)
        end
    end
    for i, v in ipairs(self._forward) do
        v(event, context)
    end
end

-- 绑定转发函数
-- 转发函数应该接受event和context两个函数
-- 转发顺序即绑定顺序
function M.EventBus:bindForward(handler)
    table.insert(self._forward, handler)
end

-- 解绑转发,解除指定处理函数的转发
function M.EventBus:unbindForward(handler)
    local result = {}
    for i, v in ipairs(self._forward) do
        if v ~= handler then
            table.insert(result, v)
        end
    end
    self._forward=result
end

-- 创建Eventbus的别名
function M.new()
    return M.EventBus:new()
end

return M
