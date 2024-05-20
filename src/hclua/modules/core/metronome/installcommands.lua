return function(runtime)
    runtime:requireModule('modules/core/metronome/install.lua')
    runtime:requireModule('modules/core/metronome/commands.lua')
    runtime.HC.sender
        :withDecoder(runtime.HC.metronomeCommands.decoder)
        :withConverter(runtime.HC.metronomeCommands.converter)
end