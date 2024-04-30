return function(runtime)
    local M = {}
    local eventbus=runtime:require('lib/eventbus/eventbus.lua')
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
    local function nop()
    end
    function M.World:new()
        local world = {
            eventBus=eventbus.new(),
            _printer = M.DefaultPrinter,
            _logger = M.DefaultLogger,
            _sender = M.DefaultSender,
            _timer=M.DefaultTimer,
            _triggersDisabler=nop,
            _triggersEnabler=nop,
            _variableSetter=nop,
            _variableGetter=nop,
            api={},
            params={}
        }
        setmetatable(world, self)
        return world
    end
    function M.World:disableTriggers(tag)
        self._triggersDisabler(tag)
    end
    function M.World:enableTriggers(tag)
        self._triggersEnabler(tag)
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
    function M.World:setVariable(name,data)
        self._variableSetter(name,data)
    end
    function M.World:getVariable(name)
        return self._variableGetter(name)
    end
    function M.World:log(data)
        self._logger(data)
    end
    function M.World:send(data)
        self._sender(data)
    end        
    function M.World:onLine(line)
        self.eventBus:raiseEvent('world.line',line)
    end
    function M.World:install()
        runtime.HC.eventBus=self.eventBus
        return self
    end
    function M.new()
        return M.World:new()
    end
    return M
end
