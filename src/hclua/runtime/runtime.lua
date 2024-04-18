-- 运行时类
-- 代码的基础，所有相关的代码都放在运行时内，避免污染环境
local M = {}
M.Path = 'hclua/'
M.Runtime = {}
M.Runtime.__index = M.Runtime
M.DefaultCharset = 'ansi'
M.DefaultHostType = 'cli'
function M.Runtime:new()
    local runtime = {
        -- 编码信息，定义整个环境的编码，默认ansi,实际使用应该为utf8或者gbk
        _charset = M.DefaultCharset,
        _hostType = M.DefaultHostType,
        -- 模快空间
        _modules = {},
        _required = {},
    }
    setmetatable(runtime, self)
    runtime.Utils = runtime:requireModule('runtime/utils.lua')
    return runtime
end

-- 返回环境字符编码
function M.Runtime:getCharset()
    return self._charset
end

-- 链式设置环境字符编码
function M.Runtime:withCharset(charset)
    self._charset = charset
    return self
end

-- 返回环境宿主机类型
function M.Runtime:getHostType()
    return self._hostType
end

-- 链式设置环境宿主机类型码
function M.Runtime:withHostType(hosttype)
    self._hostType = hosttype
    return self
end

-- 链式设置环境输出函数
function M.Runtime:withPrinter(printer)
    self._printer = printer
    return self
end

-- 打印数据
function M.Runtime:print(data)
    self._printer(data)
end

-- 记录日志
function M.Runtime:log(data)
    self._logger(data)
end

-- 链式设置环境日志函数
function M.Runtime:withLogger(logger)
    self._logger = logger
    return self
end
-- 从模块的path变量里require lua文件
function M.Runtime:require(path)
    if (self:loaded(path)) then
        return self._required[path]
    end
    local module = dofile(M.Path .. path)
    if module == nil then
        return nil
    end
    self._required[path] = module
    return module
end
-- 从模块的path变量里require module函数，将runtime作为参数传给module，得到实际的模块
function M.Runtime:requireModule(path)
    if (self:loaded(path)) then
        return self._required[path]
    end
    local m = self:require(path)
    if m ~= nil then
        self._required[path] = m(self)
    else
        self._required[path] = nil
    end
    return self._required[path]
end

function M.Runtime:loaded(path)
    return self._required[path] ~= nil
end
function M.Runtime:getPath()
    return M.Path
end
return M
