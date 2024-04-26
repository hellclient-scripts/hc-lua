return function(runtime)
    local M = {}
    M.World = {}
    M.World.__index = M.World
    function M.DefaultPrinter(data)
        print(data)
    end

    function M.DefaultLogger(data)
        print(data)
    end

    function M.DefaultSender(data)
        print(data)
    end
    function M.DefaultTimer(data)
        return nil
    end

    function M.World:new()
        local world = {
            _eventBus={},
            _printer = M.DefaultPrinter,
            _logger = M.DefaultLogger,
            _sender = M.DefaultSender,
            _timer=M.DefaultTimer,
            api={},
            params={}
        }
        setmetatable(world, self)
        return world
    end
    function M.World:withSender(s)
        self._sender=s
    end
    function M.World:withTimer(t)
        self._timer=t
    end
    function M.World:getTime()
        return self._timer()
    end
    function M.World:print(data)
        self._printer(data)
    end
    function M.World:log(data)
        self._logger(data)
    end
    function M.World:send(data)
        self._sender(data)
    end    
    function M.World:bindEvent(event,handler)
        if self._eventBus[event]==nil then
            self._eventBus[event]={}
        end
        table.insert(self._eventBus[event],(handler))
    end
    function M.World:raiseEvent(event,context)
        if self._eventBus[event]==nil then
            return
        end
        for i,v in ipairs(self._eventBus[event]) do
            v(context)
        end
    end
    function  M.World:unbindEvent(event,handler)
        if self._eventBus[event]==nil then
          return
       end
       local result={}
       for i,v in ipairs(eventBus[event]) do
            if v~=handler then
                table.insert(result,v)
            end
        end
        if (#result==0) then
            self._eventBus[event]=nil
        else
            self._eventBus[event]=result
        end
       
    end
    
    function M.new()
        return M.World:new()
    end
    return M
end
