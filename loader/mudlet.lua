if (Hclua~=nil) then
    return
  end
  print('loading')
  require('hclua/world/mudlet_utf8')
  Hclua:requireModule('modules/core/metronome/install.lua')
  Hclua:requireModule('modules/core/history/install.lua')

  print('loaded')