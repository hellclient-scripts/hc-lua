return function(runtime)
    runtime.commands:register('stop',function (data)
        runtime.world.eventBus:raiseEvent('core.stop',data)
    end)
end