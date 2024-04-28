return function(runtime)
    runtime:requireModule('modules/core/metronome/metronome.lua')
    runtime:requireModule('modules/core/metronome/commands.lua')
    local metronome = runtime._H.newMetronome()
    metronome:withDecoder(runtime._H.metronomeCommands.decoder)
    runtime._H.sender = metronome
    runtime._H.lines=function (data, bysemicolon)
        local sep
        local result={}
        if bysemicolon then
            sep = '[^\r\n;]+'
        else
            sep = '[^\r\n]+'
        end
        for line in string.gmatch(data, sep) do
            table.insert(result,line)
        end
        return result
    end
    runtime._H.queue = function(data,m)
        if m==nil then
            m=runtime._H.sender
        end
        m:discard()
        m:push(runtime._H.lines(data))
        return m
    end
    runtime._H.installMetronome(metronome)
end
