return function(runtime)
    runtime:requireModule('modules/core/metronome/metronome.lua')
    runtime:requireModule('modules/core/metronome/commands.lua')
    local metronome = runtime.HC.newMetronome()
    runtime.HC.sender = metronome
    runtime.HC.lines=function (data, bysemicolon)
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
    runtime.HC.queue = function(data,m)
        if m==nil then
            m=runtime.HC.sender
        end
        m:discard()
        m:resume()
        m:push(runtime.HC.lines(data))
        return m
    end
    runtime.HC.installMetronome(metronome)
end
