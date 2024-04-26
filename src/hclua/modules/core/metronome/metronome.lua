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
    runtime.world.api.newMetronome=new
    runtime.world.api.installMetronome=function (m)
        local binded=function ()
            m:play()
        end
        runtime.world:bindEvent('world.raw_timer',binded)
        m.params['binded']=binded
    end
    runtime.world.api.uninstallMetronome=function (m)
        runtime.world:unbindEvent('world.raw_timer',m.params['binded'])
    end
end
