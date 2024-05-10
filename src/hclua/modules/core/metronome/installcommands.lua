return function(runtime)
    runtime:requireModule('modules/core/metronome/install.lua')
    runtime.HC.sender:withDecoder(runtime.HC.metronomeCommands.decoder)
end