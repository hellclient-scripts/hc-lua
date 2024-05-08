return function(runtime)
    local line = runtime:requireModule('lib/line/line.lua')
    local utf8 = runtime:require('vendor/lua-utf8string/utf8string.lua')
    local M = {}
    M.utf8 = utf8
    function M.combineLinesShort(lines, nonewline)
        local result = {}
        for index, value in ipairs(lines) do
            table.insert(result, value:toShort())
        end
        local sep
        if nonewline then
            sep = ''
        else
            sep = '\n'
        end
        return table.concat(result, sep)
    end

    function M.combineLines(lines, nonewline)
        local result = {}
        for index, value in ipairs(lines) do
            table.insert(result, value.Text)
        end
        local sep
        if nonewline then
            sep = ''
        else
            sep = '\n'
        end
        return table.concat(result, sep)
    end

    function M.sliceLines(lines, start, length, max)
        if start~=nil and start<1 then
            return nil
        end
        if length~=nil and length<1 then
            return nil
        end
        local count = #lines
        if max ~= nil and length > max then
            count = max
        end
        local i = 1
        local result = {}
        while i <= count do
            table.insert(result, lines[i]:slice(start, length))
            i = i + 1
        end
        return result
    end

    function M.linesUTF8Mono(lines, start, length, max)
        if start~=nil and start<1 then
            return nil
        end
        if length~=nil and length<1 then
            return nil
        end
        local count = #lines
        if max ~= nil and length > max then
            count = max
        end
        local i = 1
        local result = {}
        while i <= count do
            table.insert(result, M.UTF8Mono(lines[i], start, length))
            i = i + 1
        end
        return result
    end

    function M.UTF8Mono(li, start, length)
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
        local u8 = utf8(li.Text)
        -- 当前utf8位置
        local position = 0
        -- 上一utf8位置
        local lastposition = 0
        -- 当前元素序号
        local index = 1
        -- 上一ansi位置
        local last = 0
        -- utf8元素总数
        local count = #u8
        -- 实际ascii开始位置
        local rawstart = 1
        -- 实际ascii长度
        local rawlength = 0
        while index <= count do
            local current = u8[index]
            -- asicc字符则位置加1,否则加2
            if current - last == 1 then
                position = position + 1
            else
                position = position + 2
            end
            -- 还未开始，将开始位置置于当前元素之后
            if position < start then
                rawstart = current + 1
            end
            -- 如果上一个utf8位置还超标,则将整个元素当作长度计算
            if lastposition +1 - start < length then
                rawlength = current - rawstart + 1
            end
            lastposition = position
            last = current
            index = index + 1
        end
        -- 最终长度不足
        if position < start then
            return line.Line:new()
        end
        return li:slice(rawstart, rawlength)
    end

    return M
end
