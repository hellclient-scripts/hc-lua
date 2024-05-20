local runtime = require('hclua/runtime/runtime')
runtime.Path = GetInfo(67) .. 'hclua/'
Hclua = runtime.Runtime:new():withCharset('gbk'):withHostType('mushclient')
local line = Hclua:requireModule('lib/line/line.lua')
local world = Hclua:requireModule('world/world.lua')
Hclua.world = world.new():install()
Hclua.world:withSender(function(data)
    Send(data)
end)
Hclua.world.params['on_timer'] = function()
    Hclua.world.eventBus:raiseEvent('world.tick')
end
local colormap = {
    'Black',
    'Red',
    'Green',
    'Yellow',
    'Blue',
    'Magenta',
    'Cyan',
    'White'
}
local boldcolormap = {
    'BrightBlack',
    'BrightRed',
    'BrightGreen',
    'BrightYellow',
    'BrightBlue',
    'BrightMagenta',
    'BrightCyan',
    'BrightWhite',
}

local function hashstyle(style)
    local result = ''
    result = style.textcolour .. '.'
    result = result .. style.backcolour .. '.'
    local flag = 0
    if style.bold then
        flag = flag + 1
    end
    if style.blink then
        flag = flag + 2
    end
    if style.ul then
        flag = flag + 4
    end
    if style.inverse then
        flag = flag + 8
    end
    result = result .. flag
    return result
end

Hclua.world.params['on_line'] = function()
    local linescount = GetLinesInBufferCount()
    local offset = 0
    -- 被wrap的行，上一行的newline是false
    -- 还需要排除Note和echo的用户输出
    while offset + linescount > 0 do
        if GetLineInfo(offset + linescount - 1, 3) or GetLineInfo(offset + linescount - 1, 4) or GetLineInfo(offset + linescount - 1, 5) then
            break
        end
        offset = offset - 1
    end
    local newline = line.Line:new()
    local last = ''
    local lastword
    local result
    for lineno = linescount + offset, linescount, 1 do
        local styles = GetStyleInfo(lineno)
        for index, value in ipairs(styles) do
            result = hashstyle(value)
            if last ~= result then
                last = result
                if lastword ~= nil and lastword.Text ~= '' then
                    newline:appendWord(lastword)
                end
                lastword = line.Word:new()
                lastword.Bold = value.bold
                lastword.Blink = value.blink
                lastword.Underlined = value.ul
                lastword.Inverse = value.inverse
                local fg = nil
                for index, color in ipairs(colormap) do
                    if (GetNormalColour(index) == value.textcolour) then
                        fg = color
                        break
                    end
                end
                for index, color in ipairs(boldcolormap) do
                    if (GetBoldColour(index) == value.textcolour) then
                        fg = color
                        break
                    end
                end
                if fg == 'White' then
                    fg = ''
                end
                if fg == nil then
                    fg = string.format("#%06X", value.textcolour)
                end
                lastword.Color = fg
                local bg = nil
                for index, color in ipairs(colormap) do
                    if (GetNormalColour(index) == value.backcolour) then
                        bg = color
                        break
                    end
                end
                for index, color in ipairs(boldcolormap) do
                    if (GetBoldColour(index) == value.backcolour) then
                        bg = color
                        break
                    end
                end
                if bg == 'Black' then
                    bg = ''
                end
                if bg == nil then
                    bg = string.format("#%06X", value.backcolour)
                end
                lastword.Background = bg
            end
            lastword.Text = lastword.Text .. value.text
        end
    end
    if lastword ~= nil and lastword.Text ~= '' then
        newline:appendWord(lastword)
    end
    Hclua.world:onLine(newline)
end
-- https://www.gammon.com.au/scripts/doc.php?function=StopEvaluatingTriggers
-- Must put on_line code in send to script instead of script name
Hclua.world:withTimer(function()
    return utils.timer()
end)
Hclua.world._triggersDisabler = function(tag)
    EnableTriggerGroup(tag, false)
end
Hclua.world._triggersEnabler = function(tag)
    EnableTriggerGroup(tag, true)
end
Hclua.world._variableSetter = function(name, value)
    setVariable(name, value)
end
Hclua.world._variableGetter = function(name)
    return getVariable(name)
end
Hclua.world._eventLineEnabler = function(enabled)
    EnableTrigger('hclua_trigger', enabled == true)
end
Hclua.world._eventTickEnabler = function(enabled)
    EnableTimer('hclua_timer', enabled == true)
end
-- Hclua.HC.lineReady = function(fn)
--     fn()
-- end
Hclua.world._userFileReader=function (name)
    local file=io.open(GetInfo(54)..'.user.'..name,'r')
    if file==nil then
        return nil
    end
    local result=file:read('*a')
    io.close(file)
    return result
end
Hclua.world._userFileWriter=function (name,data)
    local file=io.open(GetInfo(54)..'.user.'..name,'w')
    if file==nil then
        return
    end
    file:write(data)
    io.close(file)
    return
end

Hclua.world._isConnected = IsConnected
Hclua.world._connect = Connect
Hclua.world._disconnect = Disconnect
Hclua.world.params['on_connect'] = function()
    Hclua.world.eventBus:raiseEvent('world.connect')
end
Hclua.world.params['on_disconnect'] = function()
    Hclua.world.eventBus:raiseEvent('world.disconnect')
end
print('请在你脚本的connect事件中调用 Hclua.world.params.on_connect()')
print('请在你脚本的disconnect事件中调用 Hclua.world.params.on_disconnect()')
Hclua.world.params['on_alias'] = function(n, l, w)
    Hclua.HC.exec(w[2] or '', w[4] or '')
end


AddTriggerEx('hclua_trigger', '^.*$', 'Hclua.world.params.on_line()',
    trigger_flag.Enabled + trigger_flag.KeepEvaluating + trigger_flag.RegularExpression + trigger_flag.Replace +
    trigger_flag.Temporary, -1, 0, '', '', sendto.script, 1)
AddTimer('hclua_timer', 0, 0, 0.1, '', timer_flag.Enabled + timer_flag.Temporary + timer_flag.ActiveWhenClosed,
    'Hclua.world.params.on_timer')

AddAlias('hclua_alias', '^#hclua( (\\S+)(\\s+(.+))?)?$', '',
    alias_flag.Enabled + alias_flag.RegularExpression + alias_flag.Replace + alias_flag.Temporary,
    'Hclua.world.params.on_alias')
