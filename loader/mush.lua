if (Hclua~=nil) then
    return
  end
  print('loading')
  package.path = package.path ..";"..GetInfo(67).."/?.lua"
  require('hclua/world/mush_gbk')
  Hclua:requireModule('modules/core/metronome/install.lua')
  print('loaded')