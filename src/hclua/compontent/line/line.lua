return function(runtime)
    local M = {}
    M._json = runtime:require('vendor/json.lua/json.lua')
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
    function M.Line:appendWord(w)
        self.Text=self.Text..w.Text
        table.insert(self.Words,w)
        return self
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
    return M
end
