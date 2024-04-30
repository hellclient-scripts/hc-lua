local lu = dofile('../../src/hclua/vendor/luaunit/luaunit.lua')
local runtime = dofile('../../src/hclua/runtime/runtime.lua')
runtime.Path = '../../src/hclua/'
local rt = runtime.Runtime:new()
local history = rt:requireModule('compontent/history/history.lua')
function format(data)
    return table.concat(data,';')
end
function TestHistory()
    local h = history.new(5)
    lu.assertEquals(h:current(),nil)
    lu.assertEquals(h:getLength(), 5)
    for i = 0, 6, 1 do
        h:onLine(i)
        lu.assertEquals(h:current(), i)
    end
    lu.assertEquals(h:current(),6)
    lu.assertEquals(format(h:getLines(1)),'6')
    lu.assertEquals(format(h:getLines(2)),'6;5')
    lu.assertEquals(format(h:getLines(5)),'6;5;4;3;2')
    lu.assertEquals(format(h:getLines(10)),'6;5;4;3;2')
    lu.assertEquals(format(h:getLines(1,0)),'6')
    lu.assertEquals(h:getLines(1,-1),nil)
    lu.assertEquals(format(h:getLines(1,4)),'2')
    lu.assertEquals(h:getLines(1,5),nil)
    lu.assertEquals(format(h:getLines(5,4)),'2')
    lu.assertEquals(format(h:getLines(2,1)),'5;4')

    h:withLength(6)
    lu.assertEquals(h:getLength(), 6)
    for i = 0, 6, 1 do
        h:onLine(i)
        lu.assertEquals(h:current(), i)
    end
    lu.assertEquals(format(h:getLines(10)),'6;5;4;3;2')
    h:flush()
    lu.assertEquals(h:current(),nil)
    lu.assertEquals(h:getLength(), 6)
    for i = 0, 6, 1 do
        h:onLine(i)
        lu.assertEquals(h:current(), i)
    end
    lu.assertEquals(format(h:getLines(10)),'6;5;4;3;2;1')
end

os.exit(lu.LuaUnit.run())
