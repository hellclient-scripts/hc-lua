if (Hclua ~= nil) then
  return
end
print('Loading...')
package.path = package.path .. ";" .. GetInfo(67) .. "/?.lua"
require('hclua/world/mush_gbk')
Hclua:loadModules({
    -- ���ؽ�������ͨ��ָ��ģ�顣����Ļ����Բ�����modules/core/metronome/install.lua
  'modules/core/metronome/installcommands.lua',
    -- �������ý�����ģ��
  'modules/core/metronome/install.lua',
    -- ������ʷ��¼�ͼ�¼��ģ��
  'modules/core/history/install.lua',
})
print('Loaded.')
print('Hc-lua version ' .. Hclua.Module.version() .. '\n')