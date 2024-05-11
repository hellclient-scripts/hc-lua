-- 运行时类
-- 代码的基础，所有相关的代码都放在运行时内，避免污染环境
local M = {}
-- 大版本
M.versionMajor = 0
-- 子版本
M.versionMinor = 20240507
-- 补丁
M.versionPatch = 0
M.DefaultPrinter = function(data)
    print(data)
end
M.DefaultLogger = function(data)
    print(data)
end
-- 字符串格式的版本
function M.version()
    return M.versionMajor .. '.' .. M.versionMinor .. '.' .. M.versionPatch
end

-- 判断当前版本是否比指定的版本要早
-- 用于自定义子模块做兼容性设置
function M.beforeVersion(major, minor, patch)
    if major == nil or major < M.versionMajor then
        return true
    end
    if minor == nil or minor < M.versionMinor then
        return true
    end
    if patch == nil or patch < M.versionPatch then
        return true
    end
    return false
end

M.Path = 'hclua/'
M.Runtime = {}
M.Runtime.__index = M.Runtime
M.DefaultCharset = 'ansi'
M.DefaultHostType = 'cli'
function M.Runtime:new()
    local runtime = {
        _printer = M.DefaultPrinter,
        _logger = M.DefaultLogger,
        -- 编码信息，定义整个环境的编码，默认ansi,实际使用应该为utf8或者gbk
        _charset = M.DefaultCharset,
        _hostType = M.DefaultHostType,
        -- 模快空间
        _modules = {},
        _required = {},
        HC = {},
        world = nil,
        Module = M
    }
    setmetatable(runtime, self)
    runtime.HC.utils = runtime:requireModule('runtime/utils.lua')
    runtime.commands = runtime:require('lib/commands/commands.lua').new(function(cmd, data)
        runtime:print('HCLua version ' .. M.version())
        if (cmd ~= nil and cmd ~= '') then
            runtime:print('Command [' .. cmd .. '] not registered.')
        end
        runtime:print('Press ' .. runtime.world:getCommandPrefix() .. 'help to get commands list.')
    end)
    runtime.commands:register('help', function(data)
        data = data or ''
        if data == '' then
            local list = runtime.commands:list()
            runtime:print('HCLua version ' .. M.version())
            runtime:print('HCLua commands list:')
            for index, value in ipairs(list) do
                runtime:print('  ' .. value:id() .. ' : ' .. value:intro())
            end
            runtime:print('')
            runtime:print(runtime.world:getCommandPrefix() .. 'help [command] to show command help detail.')
            return
        end
        local cmd = runtime.commands:getCommand(data)
        if cmd == nil then
            runtime:print('HCLua version ' .. M.version())
            runtime:print('Command [' .. data .. '] not registered.')
            return
        end
        runtime:print('HCLua version ' .. M.version())
        runtime:print('Help command <' .. data .. '>.')
        runtime:print('  ' .. cmd:desc())
    end):withIntro('Command help.')

    runtime.HC.exec = function(id, data)
        runtime.commands:exec(id, data)
    end
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

function M.Runtime:loadModules(list)
    for index, value in ipairs(list) do
        self:requireModule(value)
    end
end

function M.Runtime:loaded(path)
    return self._required[path] ~= nil
end

function M.Runtime:getPath()
    return M.Path
end

return M
