return function(runtime)
    local M = {}
    M._json = runtime:require('vendor/json.lua/json.lua')
    -- line类，标准化mud的line信息
    M.Line = {}
    M.Line.__index = M.Line
    M.Colors={
        Black=1,
        Red=2,
        Green=3,
        Yellow=4,
        Blue=5,
        Magenta=6,
        Cyan=7,
        White=8,
        BrightBlack=9,
        BrightRed=10,
        BrightGreen=11,
        BrightYellow=12,
        BrightBlue=13,
        BrightMagenta=14,
        BrightCyan=15,
        BrightWhite=16
    }
    M.Colors['']=0
    function M.Line:new()
        local line = {
            Words = {},
            Text = '',
        }
        setmetatable(line, self)
        return line
    end
    function M.Line:appendWord(w)
        self.Text=self.Text..w.Text
        table.insert(self.Words,w)
        return self
    end
    function M.Line:toShort()
        local result=''
        for index, value in ipairs(self.Words) do
            result=result..value:toShort()
        end
        return result
    end
    M.parseLine = function(line)
        local data=M._json.decode(line)
        local line=M.Line:new()
        line.Text=data.Text
        line.Words=data.Words
        return line
    end
    M.Word = {}
    M.Word.__index = M.Word
    function M.Word:new()
        local word = {
            Text = '',
            Color = '',
            Background = '',
            Bold = false,
            Underlined = false,
            Blinking = false,
            Inverse = false,
        }
        setmetatable(word, self)
        return word
    end
    function M.Word:toShort()
        return self:getShortStyle()..self.Text:gsub('#','##')
    end
    function M.Word:getShortStyle()
        local result='#'
        if #(self.Color)>0 and self.Color[1]=='#' then
            result=result..'1'..string.sub(self.Color,2)
        else
            result=result..'0'..string.char(65+M.Colors[self.Color])..string.char(65+M.Colors[self.Background])
        end
        local flag=0
        if self.Bold then
            flag=flag+1
        end
        if self.Underlined then
            flag=flag+2
        end
        if self.Blinking then
            flag=flag+4
        end
        if self.Inverse then
            flag=flag+8
        end
        result=result..string.format('%01X',flag)
        return result
    end
    return M
end
