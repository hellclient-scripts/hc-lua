local runtime=require('hclua/runtime/runtime')
runtime.Path=getMudletHomeDir()..'/hclua/'
Hclua=runtime.Runtime:new():withCharset('utf8'):withHostType('mudlet')
local world=Hclua:requireModule('world/world.lua')
Hclua.world=world.new()
Hclua.world:withSender(function (data)
    send(data)
end)
Hclua.world:withTimer(getEpoch)
Hclua.world.params['timer_id']=tempTimer(0.05,function ()
    Hclua.world:raiseEvent('world.raw_timer')
end,true)
Hclua.world._triggerDisabler=function (tag)
    enableTrigger(tag)
end
Hclua.world._triggerEnabler=function (tag)
    disableTrigger(tag)
end