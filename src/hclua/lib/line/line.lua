return function(runtime)
    local M = {}
    -- ansi标准色彩对应偏移量
    M.Colors = {
        Black = 1,
        Red = 2,
        Green = 3,
        Yellow = 4,
        Blue = 5,
        Magenta = 6,
        Cyan = 7,
        White = 8,
        BrightBlack = 9,
        BrightRed = 10,
        BrightGreen = 11,
        BrightYellow = 12,
        BrightBlue = 13,
        BrightMagenta = 14,
        BrightCyan = 15,
        BrightWhite = 16
    }

    -- 设置flag位，成功返回true,失败false
    local function setflag(word, data)
        local flag = tonumber('0x' .. data)
        if flag == nil or flag > 16 or flag < 0 then
            return false
        end
        if flag >= 8 then
            word.Inverse = true
            flag = flag - 8
        end
        if flag >= 4 then
            word.Blinking = true
            flag = flag - 4
        end
        if flag >= 2 then
            word.Underlined = true
            flag = flag - 2
        end
        if flag == 1 then
            word.Bold = true
        end
        return true
    end

    M.Colors[''] = 0
    M.ColorValues = {}
    for key, value in pairs(M.Colors) do
        M.ColorValues[value] = key
    end

    -- line类，标准化mud的line信息
    M.Line = {}
    M.Line.__index = M.Line
    function M.Line:new()
        local line = {
            Words = {},
            Text = '',
        }
        setmetatable(line, self)
        return line
    end

    -- 向行中追加词组
    -- 同样样式的单词会被合并
    function M.Line:appendWord(w)
        self.Text = self.Text .. w.Text
        if #self.Words>0 then
            local last=self.Words[#self.Words]
            if last:getShortStyle()==w:getShortStyle() then
                self.Words[#self.Words]=w:copyStyle(last.Text..w.Text)
                return self
            end
        end
        table.insert(self.Words, w)
        return self
    end

    -- 将行转为简写形式
    function M.Line:toShort()
        local result = ''
        for index, value in ipairs(self.Words) do
            result = result .. value:toShort()
        end
        return result
    end

    -- 获取子行
    function M.Line:slice(start, length)
        if start == nil then
            start = 1
        end
        if start < 1 then
            return nil
        end
        if length == nil then
            length = 1
        end
        if length < 1 then
            return nil
        end
        local skip = start - 1
        local result = M.Line:new()
        for index, value in ipairs(self.Words) do
            if #value.Text <= skip then
                -- 跳过整个word
                skip = skip - #value.Text
            else
                if skip + length > #value.Text then
                    -- 部分裁切
                    result:appendWord(value:copyStyle(string.sub(value.Text, skip+1)))
                    length = length - (#value.Text - skip)
                    skip = 0
                else
                    -- 全部切玩
                    result:appendWord(value:copyStyle(string.sub(value.Text, skip+1, skip+length)))
                    return result
                end
            end
        end
        return result
    end

    M.parseLine = function(data)
        local line = M.Line:new()
        local word
        local index = 1
        local length = #data
        while index <= length do
            local char = string.sub(data, index, index)
            -- 转义
            if char == '#' then
                local left = length - index
                if left < 1 then
                    -- 孤立的#
                    return nil
                end
                local next = string.sub(data, index + 1, index + 1)
                if next == '#' then
                    if word == nil then
                        return nil
                    end
                    index = index + 1
                    word.Text = word.Text .. '#'
                elseif left > 3 and next == '0' then
                    -- #0AA0格式
                    local fg = M.ColorValues[string.byte(string.sub(data, index + 2, index + 2)) - 65]
                    local bg = M.ColorValues[string.byte(string.sub(data, index + 3, index + 3)) - 65]
                    if fg == nil or bg == nil then
                        -- 无效颜色
                        return nil
                    end
                    if word ~= nil then
                        line:pushWord(word)
                    end
                    word = M.Word:new()
                    word.Color = fg
                    word.Background = bg
                    if not setflag(word, string.sub(data, index + 4, index + 4)) then
                        -- flag无效
                        return nil
                    end
                    index = index + 4
                elseif left > 13 and next == '1' then
                    -- #1RRGGBBRRGGBB0格式
                    if word ~= nil then
                        line:pushWord(word)
                    end
                    word = M.Word:new()
                    word.Color = '#' .. string.sub(data, index + 2, index + 7)
                    word.Background = '#' .. string.sub(data, index + 8, index + 13)
                    if not setflag(word, string.sub(data, index + 14, index + 14)) then
                        -- flag无效
                        return nil
                    end
                    index = index + 14
                else
                    return nil
                end
            else
                -- 无效，应该都有样式开头
                if word == nil then
                    return nil
                end
                word.Text = word.Text .. char
            end
            index = index + 1
        end
        if word ~= nil then
            line:appendWord(word)
        end
        return line
    end
    -- 词组类,词组代表样式完全相同的连续文字
    M.Word = {}
    M.Word.__index = M.Word
    function M.Word:new()
        local word = {
            -- 正文
            Text = '',
            -- 前景,ansi色以M.Colors的键为准
            Color = '',
            -- 背景色,ansi色以M.Colors的键为准
            Background = '',
            -- 是否加粗
            Bold = false,
            -- 是否有下划线
            Underlined = false,
            -- 是否闪烁
            Blinking = false,
            -- 是否为反转色
            Inverse = false,
        }
        setmetatable(word, self)
        return word
    end

    -- 转为简写格式
    function M.Word:toShort()
        return self:getShortStyle() .. self.Text:gsub('#', '##')
    end

    function M.Word:copyStyle(text)
        if text == nil then
            text = ''
        end
        local w = M.Word:new()
        w.Text = text
        w.Color = self.Color
        w.Background = self.Background
        w.Bold = self.Bold
        w.Underlined = self.Underlined
        w.Blinking = self.Blinking
        w.Inverse = self.Inverse
        return w
    end

    -- 将样式转为简写格式
    function M.Word:getShortStyle()
        local result = '#'
        if #(self.Color) > 0 and self.Color[1] == '#' then
            result = result .. '1' .. string.sub(self.Color, 2)
        else
            result = result .. '0' .. string.char(65 + M.Colors[self.Color]) .. string.char(65 +
                M.Colors[self.Background])
        end
        local flag = 0
        if self.Bold then
            flag = flag + 1
        end
        if self.Underlined then
            flag = flag + 2
        end
        if self.Blinking then
            flag = flag + 4
        end
        if self.Inverse then
            flag = flag + 8
        end
        result = result .. string.format('%01X', flag)
        return result
    end

    return M
end
