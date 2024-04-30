return function (runtime)
    local metronome=Hclua:requireModule('compontent/metronome/metronome.lua')
    local function new()
        local m=metronome.new()
        m:withSender(function (metronome, cmd)
            runtime.world:send(cmd)
        end)
        m:withTimer(function ()
            return runtime.world:getTime()
        end)
        return m
    end
    runtime.HC.newMetronome=new
    runtime.HC.installMetronome=function (m)
        local binded=function ()
            m:play()
        end
        runtime.world.eventBus:bindEvent('world.tick',binded)
        m.params['binded']=binded
    end
    runtime.HC.uninstallMetronome=function (m)
        runtime.world:unbindEvent('world.tick',m.params['binded'])
    end
end
