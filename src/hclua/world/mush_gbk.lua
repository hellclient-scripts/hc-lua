local runtime=require('hclua/runtime/runtime')
runtime.Path=GetInfo(67)..'hclua/'
Hclua=runtime.Runtime:new():withCharset('gbk'):withHostType('mushclient')
local world=Hclua:requireModule('world/world.lua')
Hclua.world=world.new()
Hclua.world:withSender(function (data)
    Send(data)
end)
Hclua.world.params['on_timer']=function ()
    Hclua.world.eventBus:raiseEvent('world.raw_timer')    
end
AddTimer('hclua_timer',0,0,0.1,'',timer_flag.Enabled or timer_flag.Temporary or timer_flag.ActiveWhenClosed ,'Hclua.world.params.on_timer')
Hclua.world:withTimer(function ()
    return utils.timer()
end)
Hclua.world._triggerDisabler=function (tag)
    EnableTriggers(tag,false)
end
Hclua.world._triggerEnabler=function (tag)
    EnableTriggers(tag,true)
end