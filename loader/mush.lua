if (Hclua~=nil) then
    return
  end
  print('loading')
  package.path = package.path ..";"..GetInfo(67).."/?.lua"
  require('hclua/world/mush_gbk')
  Hclua:loadModules({
    'modules/core/metronome/installcommands.lua',
    'modules/core/metronome/install.lua',
    'modules/core/history/install.lua',
  })
  print('loaded')