if (Hclua ~= nil) then
  return
end
print('Loading...')
package.path = package.path .. ";" .. GetInfo(67) .. "/?.lua"
require('hclua/world/mush_gbk')
Hclua:loadModules({
    -- 加载节拍器和通用指令模块。引入的话可以不引用modules/core/metronome/install.lua
  'modules/core/metronome/installcommands.lua',
    -- 单独引用节拍器模块
  'modules/core/metronome/install.lua',
    -- 引用历史记录和记录器模块
  'modules/core/history/install.lua',
})
print('Loaded.')
print('Hc-lua version ' .. Hclua.Module.version() .. '\n')