return function(runtime)
    local history=runtime:requireModule('compontent/history/history.lua')
    local lineutils=runtime:requireModule('compontent/lineutils/lineutils.lua')

    runtime.HC.history=history.new(200)
    runtime.HC.eventBus:bindEvent('world.lineInit',function (line)
        runtime.HC.history:onLine(line)
    end)
    runtime.HC.recorder=runtime.HC.history:createRecorder()
    runtime.HC.lineutils=lineutils
end
