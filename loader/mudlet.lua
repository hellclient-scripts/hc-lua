if (Hclua~=nil) then
    return
  end
  print('loading')
  require('hclua/world/mudlet_utf8')
  Hclua:loadModules({
    'modules/core/metronome/install.lua',
    'modules/core/history/install.lua',
  })
  print('loaded')