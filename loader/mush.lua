if (Hclua ~= nil) then
  return
end
print('Loading...')
package.path = package.path .. ";" .. GetInfo(67) .. "/?.lua"
require('hclua/world/mush_gbk')
Hclua:loadModules({
  -- ���س���ָ��
  'modules/core/commands/install.lua',
  -- ���ؽ�������ͨ��ָ��ģ�顣����Ļ����Բ�����modules/core/metronome/install.lua
  'modules/core/metronome/installcommands.lua',
  -- �������ý�����ģ��
  'modules/core/metronome/install.lua',
  -- ������ʷ��¼�ͼ�¼��ģ��
  'modules/core/history/install.lua',
})

-- �Ƿ���line�¼�
Hclua.World:enableEventLine(true)
-- �Ƿ���tick�¼�
Hclua.World:enableEventTick(true)
-- ָ����ʾ��ǰ׺
Hclua.World:withCommandPrefix('#hclua ')

print('Loaded.')
print('HCLua version ' .. Hclua.Module.version() .. '\n')
