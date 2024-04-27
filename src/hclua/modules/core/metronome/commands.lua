return function(runtime)
    local M = {}
    M._commands = {}
    M.register = function(command, handler)
        M._commands[command] = handler
    end
    M.decoder = function(metronome, data)
        if (#data > 0 and string.sub(data, 1, 1) == '#') then
            local cmd, sep, param = string.match(data, "^#([^ ]+)(%s*)(.-)$")
            if cmd ~= nil then
                if M._commands[cmd] ~= nil then
                    return M._commands[cmd](metronome, param)
                end
            end
        end
        return data
    end
    M.register('wait', function(metronome, param)
        return function(metronome)
            metronome:wait(param / 1000)
        end
    end)
    M.register('pause', function(metronome, param)
        return function(metronome)
            metronome:pause()
        end
    end)
    M.register('print', function(metronome, param)
        return function(metronome)
            print(param)
        end
    end)
    M.register('t+', function(metronome, param)
        return function(metronome)
            runtime.world:enableTriggers(param)
        end
    end)
    M.register('t-', function(metronome, param)
        return function(metronome)
            runtime.world:disableTriggers(param)
        end
    end)

    runtime.world.api.metronomeCommands = M
    return M
end
