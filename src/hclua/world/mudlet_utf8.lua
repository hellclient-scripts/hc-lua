local runtime = require('hclua/runtime/runtime')

runtime.Path = getMudletHomeDir() .. '/hclua/'
Hclua = runtime.Runtime:new():withCharset('utf8'):withHostType('mudlet')

local line = Hclua:requireModule('compontent/line/line.lua')
local world = Hclua:requireModule('world/world.lua')
Hclua.world = world.new()
Hclua.world:withSender(function(data)
    send(data)
end)
Hclua.world:withTimer(getEpoch)
Hclua.world.params['timer_id'] = tempTimer(0.05, function()
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
    local w = line.Word:new()
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
    if format==nil then
        return result
    end
    result = format.foreground[1] .. '.' .. format.foreground[2] .. '.' .. format.foreground[2] .. '.'
    result = result .. format.background[1] .. '.' .. format.background[2] .. '.' .. format.background[2] .. '.'
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
createBuffer('hclua_line')
local function online()
    local all = getCurrentLine()
    selectCurrentLine()
    copy()
    clearWindow('hclua_line')
    paste('hclua_line')
    moveCursor('hclua_line',utf8.len(all), 0)
    insertText('hclua_line',' ')
    
    local newline = line.Line:new()
    if all == '' then
        return
    end
    local last = ''
    local text = ''
    local lastresult
    for i = 0, utf8.len(all)-1, 1 do
        moveCursor('hclua_line',i, 0)
        selectSection('hclua_line',i, 1)
        local result = getTextFormat('hclua_line')
        local format = hashformat(result)
        if format ~= last then
            if text ~= '' then
                local word = newword(lastresult)
                word.Text = text
                newline:appendWord(word)
            end
            text=''
            last = format
            lastresult=result
        end
        text = text .. getSelection('hclua_line')
    end
    if text ~= '' then
        local word = newword(lastresult)
        word.Text = text
        newline:appendWord(word)
    end
    Hclua.world.eventBus:raiseEvent('world.line',newline)
end

Hclua.world.params['trigger_id'] = tempComplexRegexTrigger('', '.*', function()
    online()
end, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, nil)
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
