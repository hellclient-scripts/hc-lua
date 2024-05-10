return function(runtime)
    runtime.commands:register('start',function (data)
        runtime.eventBus:raiseEvent('core.start',data)
    end)
    runtime.commands:register('stop',function (data)
        runtime.eventBus:raiseEvent('core.stop',data)
    end)
end