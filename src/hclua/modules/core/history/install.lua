return function(runtime)
    local history=runtime:requireModule('compontent/history/history.lua')
    runtime.HC.history=history.new(200)
    runtime.HC.eventBus:bindEvent('world.line',function (line)
        runtime.HC.history:onLine(line)
    end)
end
