Proxy={}
Proxy.__index=Proxy

function Proxy:new()
    local proxy={
        _printer=DefaultPrinter,
        _logger=DefaultLogger,
        __sender=DefaultSender,   
    }
    setmetatable(proxy,self)
    return proxy
end
