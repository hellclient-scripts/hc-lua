if (Hclua ~= nil) then
  return
end
print('Loading HCLua...')
require('hclua/world/mudlet_utf8')
Hclua:loadModules({
  -- 加载常用指令
  'modules/core/commands/install.lua',
  -- 加载节拍器和通用指令模块。引入的话可以不引用modules/core/metronome/install.lua
  'modules/core/metronome/installcommands.lua',
  -- 单独引用节拍器模块
  'modules/core/metronome/install.lua',
  -- 引用历史记录和记录器模块
  'modules/core/history/install.lua',
})

-- 是否开启line事件
Hclua.world:enableEventLine(true)
-- 是否开启tick事件
Hclua.world:enableEventTick(true)
-- 指令提示的前缀
Hclua.world:withCommandPrefix('#hclua ')

print('HCLua loaded.')
print('HCLua version ' .. Hclua.Module.version() .. '\n')
