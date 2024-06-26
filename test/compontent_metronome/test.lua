local lu = dofile('../../src/hclua/vendor/luaunit/luaunit.lua')
local runtime = dofile('../../src/hclua/runtime/runtime.lua')
runtime.path = '../../src/hclua/'
local rt = runtime.Runtime:new()
local metronome = rt:requireModule('compontent/metronome/metronome.lua')
-- 测试用发送器
-- 已发送内容存放于sent属性内
local sender = {}
sender.__index = sender

function sender:new()
    local s = {
        sent = {}
    }
    setmetatable(s, self)
    return s
end

-- 实现数据接口
-- 函数直接以[func]储存
function sender:send(data)
    if type(data) == 'function' then
        table.insert(self.sent, '[func]')
    else
        table.insert(self.sent, data)
    end
end

-- 清空重置
function sender:reset()
    self.sent = {}
end

-- 将已发送内容转换为分号拼接的字符串
function sender:toString()
    return table.concat(self.sent, ';')
end

-- 测试用计时器
local timer = {}
timer.__index = timer
function timer:new()
    local t = {
        _time = 0
    }
    setmetatable(t, self)
    return t
end

-- 实现接口
function timer:getTime()
    return self._time
end

-- 等待t单位的时间
function timer:sleep(t)
    self._time = self._time + t
end

-- 格式化节拍器的待输出队列，便于比较
-- 合并为以分号分割的字符串，函数替换为[func]
local function formatQueue(m)
    local q = {}
    for index, value in ipairs(m:queue()) do
        for index2, value2 in ipairs(value) do
            if type(value2) == 'function' then
                table.insert(q, '[func]')
            else
                table.insert(q, value2)
            end
        end
    end
    return table.concat(q, ';')
end

-- 测试新建节拍器，及基本设置
function TestMetronomeNew()
    local m = metronome.new()
    lu.assertEquals(m:getBeats(), metronome.DefaultBeats())
    lu.assertEquals(m:getTick(), metronome.DefaultTick())
    m:withTick(-1000):withBeats(-10)
    lu.assertEquals(m:space(), metronome.DefaultBeats())
    lu.assertEquals(m:getBeats(), metronome.DefaultBeats())
    lu.assertEquals(m:getTick(), metronome.DefaultTick())
    m:withTick(500):withBeats(10)
    lu.assertEquals(m:getBeats(), 10)
    lu.assertEquals(m:getTick(), 500)
    lu.assertEquals(m:space(), 10)
    lu.assertEquals(m:paused(), false)
end

-- 测试节拍器的标准机制
function TestMetronomePlay()
    local t = timer:new()
    local s = sender:new()
    local m = metronome.new()
    m:withTick(500):withBeats(4)
    m._timer = function() return t:getTime() end
    m._sender = function(metronome, data)
        s:send(data)
    end
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '')
    -- 不分组数据
    m:push({ "1", "2", "3", "4" }, false)
    lu.assertEquals(s:toString(), '1;2;3;4')
    lu.assertEquals(formatQueue(m), '')
    lu.assertEquals(m:space(), 0)
    m:play()
    lu.assertEquals(s:toString(), '1;2;3;4')
    m:push({ "5", "6" }, false)
    lu.assertEquals(s:toString(), '1;2;3;4')
    lu.assertEquals(formatQueue(m), '5;6')
    t:sleep(500)
    m:play()
    t:sleep(1)
    lu.assertEquals(m:space(), 4)
    m:play()
    lu.assertEquals(s:toString(), '1;2;3;4;5;6')
    lu.assertEquals(m:space(), 2)
    -- 分组数据
    m:push({ "7", "8", "9" }, true)
    m:push({ "10", "11", "12", "13" }, true)
    m:push({ "15" })
    lu.assertEquals(s:toString(), '1;2;3;4;5;6')
    lu.assertEquals(formatQueue(m), '7;8;9;10;11;12;13;15')
    lu.assertEquals(m:space(), 2)
    -- 按组输出
    t:sleep(501)
    -- 需要play更新
    lu.assertEquals(m:space(), 4)
    m:play()
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7;8;9')
    lu.assertEquals(formatQueue(m), '10;11;12;13;15')
    lu.assertEquals(m:space(), 1)
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7;8;9;10;11;12;13')
    lu.assertEquals(formatQueue(m), '15')
    lu.assertEquals(m:space(), 0)
    -- send的直接插队输出
    m:send('14')
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7;8;9;10;11;12;13;14')
    lu.assertEquals(formatQueue(m), '15')
    lu.assertEquals(m:space(), 0)
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7;8;9;10;11;12;13;14;15')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    -- 超过beats的指令组，必须在空节拍才能发送
    m:push({ '16', '17', '18', '19', '20' }, true)
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7;8;9;10;11;12;13;14;15')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '16;17;18;19;20')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
    s:reset()
    m:reset()
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '')
    m:push({ 'test' })
    lu.assertEquals(s:toString(), 'test')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    s:reset()
    lu.assertEquals(s:toString(), '')
    m:push({ 'a', 'b', 'c', 'd' }, true)
    m:push({ 'e', 'f' }, true)
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), 'a;b;c;d;e;f')
    -- reset测试
    m:reset()
    lu.assertEquals(s:toString(), 'a;b;c;d')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), 'e;f')
    -- discard测试
    m:discard()
    lu.assertEquals(s:toString(), 'a;b;c;d')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(501)
    lu.assertEquals(s:toString(), 'a;b;c;d')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '')
end

-- 插入测试
function TestMetronomeInsert()
    local t = timer:new()
    local s = sender:new()
    local m = metronome.new()
    m:withTick(500):withBeats(4)
    m._timer = function() return t:getTime() end
    m._sender = function(metronome, data)
        s:send(data)
    end
    m:insert({ '1', '2', '3', '4', '6' })
    lu.assertEquals(s:toString(), '1;2;3;4')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '6')
    m:insert({ '5' })
    lu.assertEquals(s:toString(), '1;2;3;4')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '5;6')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '1;2;3;4;5;6')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '')
    m:insert({ '7', '8', '9', '10', '11' }, true)
    lu.assertEquals(s:toString(), '1;2;3;4;5;6')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '7;8;9;10;11')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7;8;9;10;11')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
end

-- 计时器填充测试
function TestMetronomeFull()
    local t = timer:new()
    local s = sender:new()
    local m = metronome.new()
    m:withTick(500):withBeats(4)
    m._timer = function() return t:getTime() end
    m._sender = function(metronome, data)
        s:send(data)
    end
    m:push({ "1", "2" }, false)
    lu.assertEquals(s:toString(), '1;2')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(250)
    m:push({ "3", "4" }, false)
    lu.assertEquals(s:toString(), '1;2;3;4')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(251)
    lu.assertEquals(s:toString(), '1;2;3;4')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '')
    m:push({ "5", "6", "7" }, false)
    lu.assertEquals(s:toString(), '1;2;3;4;5;6')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '7')
    t:sleep(250)
    m:play()
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7')
    lu.assertEquals(m:space(), 1)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(501)
    m:play()
    s:reset()
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '')
    m:push({ "a", "b" }, false)
    lu.assertEquals(s:toString(), 'a;b')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(251)
    -- 测试填充节拍
    m:fullTick()
    m:push({ "c", "d" })
    lu.assertEquals(s:toString(), 'a;b')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), 'c;d')
    t:sleep(250)
    m:play()
    lu.assertEquals(s:toString(), 'a;b;c;d')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), 'a;b;c;d')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '')
    m:push({ "e", "f" })
    lu.assertEquals(s:toString(), 'a;b;c;d;e;f')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(251)
    -- 测试完全填充
    m:full()
    m:push({ "g", "h" })
    lu.assertEquals(s:toString(), 'a;b;c;d;e;f')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), 'g;h')
    t:sleep(250)
    m:play()
    lu.assertEquals(s:toString(), 'a;b;c;d;e;f')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), 'g;h')
    t:sleep(251 - 1)
    m:play()
    lu.assertEquals(s:toString(), 'a;b;c;d;e;f')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), 'g;h')
    t:sleep(1)
    m:play()
    lu.assertEquals(s:toString(), 'a;b;c;d;e;f;g;h')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '')

    s:reset()
    m:reset()
    m:play()
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '')
    m:push({ 'A' })
    lu.assertEquals(s:toString(), 'A')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    -- 小于tick填充
    m:wait(250)
    m:push({ 'B' })
    lu.assertEquals(s:toString(), 'A')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), 'B')
    t:sleep(250)
    m:play()
    lu.assertEquals(s:toString(), 'A')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), 'B')
    t:sleep(1)
    m:play()
    lu.assertEquals(s:toString(), 'A;B')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(501 - 250 - 1)
    m:play()
    lu.assertEquals(s:toString(), 'A;B')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(1001 - (501 - 250 - 1))
    m:play()
    lu.assertEquals(s:toString(), 'A;B')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '')
    m:wait(0)
    m:play()
    lu.assertEquals(s:toString(), 'A;B')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(1)
    m:play()
    lu.assertEquals(s:toString(), 'A;B')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '')
    m:push({ "C" })
    -- 正常wait
    m:wait(1000)
    m:push({ "D" })
    lu.assertEquals(s:toString(), 'A;B;C')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), 'D')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), 'A;B;C')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), 'D')
    t:sleep(1001 - 501)
    m:play()
    lu.assertEquals(s:toString(), 'A;B;C;D')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
end

-- 暂停/继续测试
function TestPause()
    local t = timer:new()
    local s = sender:new()
    local m = metronome.new()
    m._timer = function() return t:getTime() end
    m._sender = function(metronome, data)
        s:send(data)
    end
    m:withTick(500):withBeats(4)
    m:pause()
    lu.assertEquals(m:paused(), true)
    -- pause不需要在运行状态也可使用
    m:pause()
    lu.assertEquals(m:paused(), true)
    m:push({ "1", "2", "3", "4", "5", "6" }, false)
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '1;2;3;4;5;6')
    t:sleep(1002)
    m:play()
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '1;2;3;4;5;6')
    m:resume()
    lu.assertEquals(s:toString(), '1;2;3;4')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '5;6')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '1;2;3;4;5;6')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '')
    -- resume不需要在暂停状态也可使用
    m:resume()
    lu.assertEquals(m:paused(), false)
    m:push({ "7", "8" }, false)
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7;8')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(501)
    m:resume()
    lu.assertEquals(m:paused(), false)
    m:push({ "9", "10" }, false)
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7;8;9;10')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '')
    m:discard()
    m:reset()
    s:reset()

    -- 单步测试
    m:pause()
    m:push({ "a", "b" }, false)
    m:push({ "c", "d", "e" }, true)
    m:push({ "f", "g", "h", "i", "j" }, true)
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), 'a;b;c;d;e;f;g;h;i;j')
    m:resumeNext()
    lu.assertEquals(m:paused(), true)
    lu.assertEquals(s:toString(), 'a')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), 'b;c;d;e;f;g;h;i;j')
    m:resumeNext()
    lu.assertEquals(s:toString(), 'a;b')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), 'c;d;e;f;g;h;i;j')
    m:resumeNext()
    lu.assertEquals(s:toString(), 'a;b')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), 'c;d;e;f;g;h;i;j')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), 'a;b;c;d;e')
    lu.assertEquals(m:space(), 1)
    lu.assertEquals(formatQueue(m), 'f;g;h;i;j')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), 'a;b;c;d;e')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), 'f;g;h;i;j')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), 'a;b;c;d;e')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), 'f;g;h;i;j')
    m:resumeNext()
    lu.assertEquals(s:toString(), 'a;b;c;d;e;f;g;h;i;j')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(501)
    m:play()
    m:push({ 'k' })
    lu.assertEquals(s:toString(), 'a;b;c;d;e;f;g;h;i;j')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), 'k')
    m:resume()
    lu.assertEquals(m:paused(), false)
    lu.assertEquals(s:toString(), 'a;b;c;d;e;f;g;h;i;j;k')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')


    m:discard()
    m:reset()
    s:reset()
    -- resumeNext在非paused状态可以使用，但无实际效果
    lu.assertEquals(m:paused(), false)
    m:resumeNext()
    m:push({ 'A', 'B' })
    m:push({ 'C', 'D', 'E' }, true)
    m:push({ 'F', 'G', 'H', 'I', 'J' }, true)
    lu.assertEquals(s:toString(), 'A;B')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), 'C;D;E;F;G;H;I;J')
    t:sleep(501)
    m:resumeNext()
    m:play()
    lu.assertEquals(s:toString(), 'A;B;C;D;E')
    lu.assertEquals(m:space(), 1)
    lu.assertEquals(formatQueue(m), 'F;G;H;I;J')
    t:sleep(501)
    m:resumeNext()
    m:play()
    lu.assertEquals(s:toString(), 'A;B;C;D;E;F;G;H;I;J')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
end

-- 测试用函数，如果被执行会测试失败
local function assertShouldNotExecuted()
    lu.assertEquals(true, false)
end

-- 管道转发测试
function TestPipe()
    local t = timer:new()
    local s = sender:new()
    local m = metronome.new()
    m:withTick(500):withBeats(4)
    m._timer = function() return t:getTime() end
    m._sender = function(metronome, data)
        s:send(data)
    end
    -- 转发目标，只记录数据
    local s2 = sender:new()
    local m2 = metronome.new()
    m2:withTick(1):withBeats(9999)
    m2._timer = function() return t:getTime() end
    m2._sender = function(metronome, data)
        s2:send(data)
    end
    m:withPipe(m2)
    -- 直接send测试
    m:send('a')
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(s2:toString(), 'a')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    -- 标准流程测试
    m:push({ 'b', 'c' })
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(s2:toString(), 'a;b;c')
    lu.assertEquals(m:space(), 1)
    lu.assertEquals(formatQueue(m), '')
    -- 函数不被转发测试
    m:push({ assertShouldNotExecuted, 'd' }, true)
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(s2:toString(), 'a;b;c')
    lu.assertEquals(m:space(), 1)
    lu.assertEquals(formatQueue(m), '[func];d')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(s2:toString(), 'a;b;c;d')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    m:push({ 'e', 'f', 'g', 'h', 'i' }, true)
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(s2:toString(), 'a;b;c;d;e;f;g;h;i')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
    -- 取消转发测试
    m:withPipe(nil)
    m:reset()
    m:send('A')
    lu.assertEquals(s:toString(), 'A')
    lu.assertEquals(s2:toString(), 'a;b;c;d;e;f;g;h;i')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    m:push({ 'B', 'C' })
    lu.assertEquals(s:toString(), 'A;B;C')
    lu.assertEquals(s2:toString(), 'a;b;c;d;e;f;g;h;i')
    lu.assertEquals(m:space(), 1)
    lu.assertEquals(formatQueue(m), '')
end

-- 接码测试
function TestDecoder()
    local t = timer:new()
    local s = sender:new()
    local m = metronome.new()
    m:withTick(500):withBeats(4)
    m._timer = function() return t:getTime() end
    m._sender = function(metronome, data)
        s:send(data)
    end
    -- 指定解码器，#wait 数字可以实现暂停xx秒，类似zmud #wait
    m:withDecoder(function(metronome, data)
        if type(data) == 'string' then
            if string.sub(data, 1, 6) == '#wait ' then
                return function(metronome)
                    metronome:wait(string.sub(data, 7) - 0)
                end
            end
        end
        return data
    end)
    -- 函数测试
    m:push({ '1', function(metronome)
        metronome:wait(1000)
    end, '2' })
    lu.assertEquals(s:toString(), '1')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '2')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '1')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '2')
    t:sleep(1001 - 501)
    m:play()
    lu.assertEquals(s:toString(), '1;2')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    s:reset()
    m:reset()
    -- 转码测试
    m:push({ '1', '#wait 1000', '2' })
    lu.assertEquals(s:toString(), '1')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '2')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '1')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '2')
    t:sleep(1001 - 501)
    m:play()
    lu.assertEquals(s:toString(), '1;2')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    s:reset()
    m:reset()
    -- 函数在按组发送失效测试
    m:push({ '1', assertShouldNotExecuted, '2' }, true)
    lu.assertEquals(s:toString(), '1;2')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '')
    s:reset()
    m:reset()
    m:full()
    -- 函数在发送前不失效
    m:push({ '1', assertShouldNotExecuted, '2' }, true)
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '1;[func];2')

    s:reset()
    m:discard()
    m:reset()
    s:send(function() end)
    lu.assertEquals(s:toString(), '[func]')
    s:reset()
    m:reset()
    -- send指令不发送函数测试
    m:send(function() end)
    lu.assertEquals(s:toString(), '')
end

-- 测试占位
function TestHold()
    local t = timer:new()
    local s = sender:new()
    local m = metronome.new()
    m:withTick(500):withBeats(4)
    m._timer = function() return t:getTime() end
    m._sender = function(metronome, data)
        s:send(data)
    end
    m:push({ 1 })
    lu.assertEquals(s:toString(), '1')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    m:hold(-1)
    lu.assertEquals(s:toString(), '1')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    m:hold(0)
    lu.assertEquals(s:toString(), '1')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    m:hold(2)
    lu.assertEquals(s:toString(), '1')
    lu.assertEquals(m:space(), 1)
    lu.assertEquals(formatQueue(m), '')
    m:hold(2)
    lu.assertEquals(s:toString(), '1')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
    -- 过填充不会影响之后的tick
    m:push({ 2 })
    lu.assertEquals(s:toString(), '1')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '2')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '1;2')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
end

function TestResumeNext()
    local t = timer:new()
    local s = sender:new()
    local m = metronome.new()
    m:withTick(500):withBeats(4)
    m._timer = function() return t:getTime() end
    m._sender = function(metronome, data)
        s:send(data)
    end
    -- 不在pause状态无效
    m:resumeNext()
    m:pause()
    m:push({ '1' })
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '1')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '1')
    -- resume清除resumeNext状态
    m:discard()
    m:full()
    m:resumeNext()
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
    m:resume()
    m:pause()
    m:push({ '2' })
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '2')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '2')
    -- 多次resumeNext只生效一次
    m:discard()
    m:reset()
    m:full()
    m:push({ '3', '4', '5', '6' })
    m:resumeNext()
    m:resumeNext()
    m:resumeNext()
    m:resumeNext()
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '3;4;5;6')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '3')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '4;5;6')
    -- 测试函数相关
    m:discard()
    m:reset()
    s:reset()
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '')
    m:pause()
    m:push({ function()
        -- 空函数
    end })
    m:push({ '1' })
    m:resumeNext()
    lu.assertEquals(s:toString(), '1')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    m:push({ function()
        m:stopResumeNext()
    end })
    m:push({ '1' })
    m:resumeNext()
    lu.assertEquals(s:toString(), '1')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '1')
end

function TestResend()
    local t = timer:new()
    local s = sender:new()
    local m = metronome.new()
    m:withTick(500):withBeats(4)
    m._timer = function() return t:getTime() end
    m._sender = function(metronome, data)
        s:send(data)
    end
    m:pause()
    m:resend()
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '')
    m:push({ '1' })
    m:resumeNext()
    lu.assertEquals(s:toString(), '1')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    lu.assertEquals(table.concat(m:last(), ';'), '1')
    m:resend()
    lu.assertEquals(s:toString(), '1;1')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '')
    lu.assertEquals(table.concat(m:last(), ';'), '1')
    m:full()
    m:resend()
    m:resend()
    m:resend()
    m:resend()
    lu.assertEquals(s:toString(), '1;1')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '1;1;1;1')
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '1;1;1')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '1;1;1')
end

function TestQueue()
    local t = timer:new()
    local s = sender:new()
    local m = metronome.new()
    m:withTick(500):withBeats(4)
    m._timer = function() return t:getTime() end
    m._sender = function(metronome, data)
        s:send(data)
    end
    m:full()
    m:push({ '1', '2', '3' }, true)
    m:push({ '4', '5', '6' }, true)
    local result = m:queue()
    lu.assertEquals(#result, 2)
    lu.assertEquals(table.concat(result[1], ';'), '1;2;3')
    lu.assertEquals(table.concat(result[2], ';'), '4;5;6')

    lu.assertEquals(table.concat(m:queue(true), ';'), '1;2;3;4;5;6')
end

function TestConverter()
    local t = timer:new()
    local s = sender:new()
    local m = metronome.new()
    m:withTick(500):withBeats(4)
    m._timer = function() return t:getTime() end
    m._sender = function(metronome, data)
        s:send(data)
    end
    local decoded = false
    local converted = false
    m:withConverter(function(m, cmds)
        if #cmds == 1 and cmds[1] == '#decoded' then
            cmds[1] = "#converted"
            cmds[2]="#converted2"
            converted = true
        end
        return cmds
    end)
    m:withDecoder(function(m, data)
        decoded = true
        if data == '#test' then
            decoded = true
            return '#decoded'
        end
        return data
    end)
    m:full()
    m:push({ 'a','b','#test' })
    lu.assertEquals(decoded, false)
    lu.assertEquals(converted, false)
    lu.assertEquals(formatQueue(m), 'a;b;#test')
    lu.assertEquals(s:toString(), '')
    t:sleep(501)
    m:play()
    lu.assertEquals(formatQueue(m), '')
    lu.assertEquals(m:space(),1)
    lu.assertEquals(decoded, true)
    lu.assertEquals(converted, true)
    lu.assertEquals(s:toString(), 'a;b;#converted;#converted2')
    -- 测试send
    s:reset()
    m:discard()
    m:reset()
    m:send('a')
    -- decoder应该不对send起作用
    m:send('#test')
    -- converter应该对send起作用
    m:send('#decoded')
    lu.assertEquals(s:toString(), 'a;#test;#converted;#converted2')
end

os.exit(lu.LuaUnit.run())
