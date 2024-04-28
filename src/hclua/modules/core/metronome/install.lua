return function(runtime)
    runtime:requireModule('modules/core/metronome/metronome.lua')
    runtime:requireModule('modules/core/metronome/commands.lua')
    local metronome = runtime.world.api.newMetronome()
    metronome:withDecoder(runtime.world.api.metronomeCommands.decoder)
    runtime.world.api.metronome = metronome
    runtime.world.api.push = function(cmds, grouped)
        runtime.world.api.metronome:push(cmds, grouped)
    end
    runtime.world.api.pause = function()
        runtime.world.api.metronome:pause()
    end
    runtime.world.api.resume = function()
        runtime.world.api.metronome:resume()
    end
    runtime.world.api.resumeNext = function()
        runtime.world.api.metronome:resumeNext()
    end
    runtime.world.api.stopResumeNext = function()
        runtime.world.api.metronome:resumeNext()
    end
    runtime.world.api.resend = function()
        runtime.world.api.metronome:resend()
    end
    runtime.world.api.wait = function(data)
        runtime.world.api.metronome:wait(data / 1000)
    end
    runtime.world.api.queue = function(data, bysemicolon, noresume)
        runtime.world.api.metronome:discard()
        if (not noresume) then
            runtime.world.api.metronome:resume()
        end
        local sep
        if bysemicolon then
            sep = '[^\r\n;]+'
        else
            sep = '[^\r\n]+'
        end
        for line in string.gmatch(data, sep) do
            runtime.world.api.metronome:push({ line })
        end
    end
    runtime.world.api.discard = function()
        runtime.world.api.metronome:discard()
    end
    runtime.world.api.send=function (data)
        runtime.world.api.metronome:send(data)
    end
    runtime.world.api.installMetronome(metronome)
end
