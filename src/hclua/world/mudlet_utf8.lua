local runtime = require('hclua/runtime/runtime')

runtime.path = getMudletHomeDir() .. '/hclua/'
Hclua = runtime.Runtime:new():withCharset('utf8'):withHostType('mudlet')

local linelib = Hclua:requireModule('lib/line/line.lua')
local world = Hclua:requireModule('world/world.lua')
Hclua.world = world.new():install()
Hclua.world:withSender(function(data)
    send(data)
end)
Hclua.world:withTimer(getEpoch)
Hclua.world.params['timer_id'] = tempTimer(0.1, function()
    Hclua.world.eventBus:raiseEvent('world.tick')
end, true)
Hclua.world._triggerDisabler = function(tag)
    disableTrigger(tag)
end
Hclua.world._triggersEnabler = function(tag)
    enableTrigger(tag)
end
local colormap = {
    '',
    'BrightBlack',
    'Black',
    'BrightRed',
    'Red',
    'BrightGreen',
    'Green',
    'BrightYellow',
    'Yellow',
    'BrightBlue',
    'Blue',
    'BrightMagenta',
    'Magenta',
    'BrightCyan',
    'Cyan',
    'BrightWhite',
    'White'
}
local function newword(format)
    local w = linelib.Word:new()
    if format ~= nil then
        local fg = nil
        for index, value in ipairs(colormap) do
            if isAnsiFgColor(index - 1) then
                fg = value
                break
            end
        end
        if fg == nil then
            fg = string.format("#%02X%02X%02X", format.foreground[1], format.foreground[2], format.foreground[3])
        end
        local bg = nil
        for index, value in ipairs(colormap) do
            if isAnsiBgColor(index - 1) then
                bg = value
                break
            end
        end
        if bg == nil then
            bg = string.format("#%02X%02X%02X", format.background[1], format.background[2], format.background[3])
        end
        w.Bold = format.bold
        w.Underlined = format.underline
        w.Inverse = format.reverse
        w.Blinking = format.italic
        w.Color = fg
        w.Background = bg
    end
    return w
end
local function hashformat(format)
    local result = ''
    if format == nil then
        return result
    end
    result = format.foreground[1] .. '.' .. format.foreground[2] .. '.' .. format.foreground[3] .. '.'
    result = result .. format.background[1] .. '.' .. format.background[2] .. '.' .. format.background[3] .. '.'
    local flag = 0
    if format.bold then
        flag = flag + 1
    end
    if format.italic then
        flag = flag + 2
    end
    if format.underline then
        flag = flag + 4
    end
    if format.reverse then
        flag = flag + 8
    end
    if format.strikeout then
        flag = flag + 16
    end
    if format.overline then
        flag = flag + 32
    end
    result = result .. flag
    return result
end
Hclua.world.params['online'] = function()
    local lineno = getLastLineNumber()
    local length = utf8.len(line)
    selectCurrentLine()
    moveCursor(length, lineno)
    insertText(' ')
    local newline = linelib.Line:new()
    local last = ''
    local lastword
    for i = 0, length - 1, 1 do
        moveCursor(i, lineno)
        selectSection(i, 1)
        local result = getTextFormat()
        local format = hashformat(result)
        if format ~= last then
            local word = newword(result)
            if lastword ~= nil then
                newline:appendWord(lastword)
            end
            lastword = word
            last = format
        end
        lastword.Text = lastword.Text .. getSelection()
    end
    if lastword ~= nil and lastword.Text ~= '' then
        newline:appendWord(lastword)
    end
    selectSection(length, 1)
    replace('')
    Hclua.world.params['current_line'] = newline
    raiseEvent('hclua.online')
end
registerAnonymousEventHandler('hclua.online', function()
    Hclua.world:onLine(Hclua.world.params['current_line'])
    local callbacks = Hclua.world.params['_lineReady']
    Hclua.world.params['_lineReady'] = {}
    for index, value in ipairs(callbacks) do
        value(Hclua.world.params['current_line'])
    end
end)
if (exists('hclua.online', 'trigger') == 0) then
    permRegexTrigger('hclua.online', '', { '^.*$' }, [[Hclua.world.params['online']()]])
end

-- Hclua.world.params['trigger_id'] = tempComplexRegexTrigger('', '.*', function()
--     online()
--     raiseEvent('hclua.online')
-- end, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil)
Hclua_Varibles = Hclua_Varibles or {}
Hclua.world._variableSetter = function(name, value)
    Hclua_Varibles[name] = value
end
Hclua.world._variableGetter = function(name)
    local data = Hclua_Varibles[name]
    if data == nil then
        return ''
    end
    return tostring(data)
end

Hclua.world._eventLineEnabler = function(enabled)
    if enabled == true then
        enableTrigger('hclua.online')
    else
        disableTrigger('hclua.online')
    end
end
Hclua.world._eventTickEnabler = function(enabled)
    if enabled == true then
        enableTimer(Hclua.world.params['timer_id'])
    else
        disableTimer(Hclua.world.params['timer_id'])
    end
end

Hclua.world.params['_lineReady'] = {}

Hclua.world._userFileReader=function (name)
    local file=io.open(getMudletHomeDir()..'/user.'..name,'r')
    if file==nil then
        return nil
    end
    local result=file:read('*a')
    io.close(file)
    return result
end
Hclua.world._userFileWriter=function (name,data)
    local file=io.open(getMudletHomeDir()..'/user.'..name,'w')
    if file==nil then
        return
    end
    file:write(data)
    io.close(file)
    return
end
-- Hclua.HC.lineReady = function(fn)
--     table.insert(Hclua.world.params['_lineReady'], fn)
-- end
-- Hclua.HC.lineReady = function(fn)
--     fn()
-- end

Hclua.world._connect = reconnect
Hclua.world._disconnect = disconnect

Hclua.world._isConnected= function()
    local host, port, connected = getConnectionInfo()
    return connected
end

registerAnonymousEventHandler("sysConnectionEvent", function()
    Hclua.world.eventBus:raiseEvent('world.connect')
end)
registerAnonymousEventHandler("sysDisconnectionEvent", function()
    Hclua.world.eventBus:raiseEvent('world.disconnect')
end)
Hclua.world.params['on_alias'] = function()
    Hclua.HC.exec(matches[3] or '', matches[5] or '')
end

if (exists('hclua.alias', 'alias') == 0) then
    permAlias('hclua.alias', '', '^#hclua( (\\S+)(\\s+(.+))?)?$', [[Hclua.world.params['on_alias']()]])
end
print('建议在触发设置界面将hclua.online触发移动至所有触发上方。')
print('建议将前景色和白色设为一致，背景色和黑色设为一致，如默认色彩配置即可。')
