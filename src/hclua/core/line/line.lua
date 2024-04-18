-- line类，标准化mud的line信息
Line={}
Line.__index=Line

function Line:new()
    local line={
        _data={},
        _string='',
    }
    setmetatable(line,self)
    return line
end