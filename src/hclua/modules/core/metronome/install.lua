return function (runtime)
    runtime:requireModule('modules/core/metronome/metronome.lua')
    runtime:requireModule('modules/core/metronome/commands.lua')
    local metronome=runtime.world.api.newMetronome()
    metronome:withDecoder(runtime.world.api.metronomeCommands.decoder)
    runtime.world.api.metronome=metronome
    runtime.world.api.push=function (cmds,grouped)
        runtime.world.api.metronome:push(cmds,grouped)
    end
    runtime.world.api.pause=function ()
        runtime.world.api.metronome:pause()
    end
    runtime.world.api.resume=function ()
        runtime.world.api.metronome:resume()
    end
    runtime.world.api.resumeNext=function ()
        runtime.world.api.metronome:resumeNext()
    end
    runtime.world.api.resend=function ()
        runtime.world.api.metronome:resend()
    end
    runtime.world.api.installMetronome(metronome)

end