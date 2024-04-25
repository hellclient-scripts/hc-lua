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

    function M.World:new()
        local world = {
            _printer = M.DefaultPrinter,
            _logger = M.DefaultLogger,
            _sender = M.DefaultSender,
        }
        setmetatable(world, self)
        return world
    end

    function M.World:print(data)
        self._printer(data)
    end
    function M.World:log(data)
        self._printer(data)
    end
    function M.World:send(data)
        self._printer(data)
    end    
    return M
end
