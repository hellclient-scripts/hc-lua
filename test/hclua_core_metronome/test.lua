local lu = dofile('../../src/hclua/vendor/luaunit/luaunit.lua')
local runtime = dofile('../../src/hclua/runtime/runtime.lua')
runtime.Path = '../../src/hclua/'
local rt = runtime.Runtime:new()
local metronome = rt:requireModule('core/metronome/metronome.lua')

local sender = {}
sender.__index = sender

function sender:new()
    local s = {
        sent = {}
    }
    setmetatable(s, self)
    return s
end

function sender:send(data)
    if type(data) == 'function' then
        table.insert(self.sent, '[func]')
    else
        table.insert(self.sent, data)
    end
end

function sender:reset()
    self.sent = {}
end

function sender:toString()
    return table.concat(self.sent, ';')
end

local timer = {}
timer.__index = timer
function timer:new()
    local t = {
        _time = 0
    }
    setmetatable(t, self)
    return t
end

function timer:getTime()
    return self._time
end

function timer:withTime(t)
    self._time = t
    return self
end

function timer:sleep(t)
    self._time = self._time + t
end

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
    m:push({ "7", "8", "9" }, true)
    m:push({ "10", "11", "12", "13" }, true)
    m:push({ "15" })
    lu.assertEquals(s:toString(), '1;2;3;4;5;6')
    lu.assertEquals(formatQueue(m), '7;8;9;10;11;12;13;15')
    lu.assertEquals(m:space(), 2)
    t:sleep(501)
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
    m:send('14')
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7;8;9;10;11;12;13;14')
    lu.assertEquals(formatQueue(m), '15')
    lu.assertEquals(m:space(), 0)
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7;8;9;10;11;12;13;14;15')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
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
    m:reset()
    lu.assertEquals(s:toString(), 'a;b;c;d')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), 'e;f')
    m:discard()
    lu.assertEquals(s:toString(), 'a;b;c;d')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(501)
    lu.assertEquals(s:toString(), 'a;b;c;d')
    lu.assertEquals(m:space(), 4)
    lu.assertEquals(formatQueue(m), '')
end

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
    m:pause()
    lu.assertEquals(m:paused(), true)
    m:push({"1","2","3","4","5","6"},false)
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
    m:resume()
    lu.assertEquals(m:paused(), false)
    m:push({"7","8"},false)
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7;8')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
    t:sleep(501)
    m:resume()
    lu.assertEquals(m:paused(), false)
    m:push({"9","10"},false)
    lu.assertEquals(s:toString(), '1;2;3;4;5;6;7;8;9;10')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '')
    m:discard()
    m:reset()
    s:reset()
    m:pause()
    m:push({"a","b"},false)
    m:push({"c","d","e"},true)
    m:push({"f","g","h","i","j"},true)
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
    m:push({'k'})
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
    lu.assertEquals(m:paused(), false)
    m:resumeNext()
    m:push({'A','B'})
    m:push({'C','D','E'},true)
    m:push({'F','G','H','I','J'},true)
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
local function assertShouldNotExecuted()
    lu.assertEquals(true, false)
end
function TestPipe()
    local t = timer:new()
    local s = sender:new()
    local m = metronome.new()
    m:withTick(500):withBeats(4)
    m._timer = function() return t:getTime() end
    m._sender = function(metronome, data)
        s:send(data)
    end
    local s2 = sender:new()
    local m2 = metronome.new()
    m2:withTick(1):withBeats(9999)
    m2._timer = function() return t:getTime() end
    m2._sender = function(metronome, data)
        s2:send(data)
    end
    m:withPipe(m2)
    m:send('a')
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(s2:toString(), 'a')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    m:push({'b','c'})
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(s2:toString(), 'a;b;c')
    lu.assertEquals(m:space(), 1)
    lu.assertEquals(formatQueue(m), '')
    m:push({assertShouldNotExecuted,'d'},true)
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
    m:push({'e','f','g','h','i'},true)
    t:sleep(501)
    m:play()
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(s2:toString(), 'a;b;c;d;e;f;g;h;i')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '')
    m:withPipe(nil)
    m:reset()
    m:send('A')
    lu.assertEquals(s:toString(), 'A')
    lu.assertEquals(s2:toString(), 'a;b;c;d;e;f;g;h;i')
    lu.assertEquals(m:space(), 3)
    lu.assertEquals(formatQueue(m), '')
    m:push({'B','C'})
    lu.assertEquals(s:toString(), 'A;B;C')
    lu.assertEquals(s2:toString(), 'a;b;c;d;e;f;g;h;i')
    lu.assertEquals(m:space(), 1)
    lu.assertEquals(formatQueue(m), '')
end


function TestDecoder()
    local t = timer:new()
    local s = sender:new()
    local m = metronome.new()
    m:withTick(500):withBeats(4)
    m._timer = function() return t:getTime() end
    m._sender = function(metronome, data)
        s:send(data)
    end
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
    m:push({ '1', assertShouldNotExecuted, '2' }, true)
    lu.assertEquals(s:toString(), '1;2')
    lu.assertEquals(m:space(), 2)
    lu.assertEquals(formatQueue(m), '')
    s:reset()
    m:reset()
    m:full()
    m:push({ '1', assertShouldNotExecuted, '2' }, true)
    lu.assertEquals(s:toString(), '')
    lu.assertEquals(m:space(), 0)
    lu.assertEquals(formatQueue(m), '1;[func];2')

    s:reset()
    m:discard()
    m:reset()
    s:send(function ()end)
    lu.assertEquals(s:toString(), '[func]')
    s:reset()
    m:reset()
    m:send(function ()end)
    lu.assertEquals(s:toString(), '')

end

os.exit(lu.LuaUnit.run())
