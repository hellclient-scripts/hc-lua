return function(runtime)
    runtime.commands:register('stop',function (data)
        runtime.eventBus:raiseEvent('core.stop',data)
    end)
end