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
    lu.assertEquals(format(h:getLines(2)),'5;6')
    lu.assertEquals(format(h:getLines(5)),'2;3;4;5;6')
    lu.assertEquals(format(h:getLines(10)),'2;3;4;5;6')
    lu.assertEquals(format(h:getLines(1,0)),'6')
    lu.assertEquals(h:getLines(1,-1),nil)
    lu.assertEquals(format(h:getLines(1,4)),'2')
    lu.assertEquals(h:getLines(1,5),nil)
    lu.assertEquals(format(h:getLines(5,4)),'2')
    lu.assertEquals(format(h:getLines(2,1)),'4;5')

    h:withLength(6)
    lu.assertEquals(h:getLength(), 6)
    for i = 0, 6, 1 do
        h:onLine(i)
        lu.assertEquals(h:current(), i)
    end
    lu.assertEquals(format(h:getLines(10)),'2;3;4;5;6')
    h:flush()
    lu.assertEquals(h:current(),nil)
    lu.assertEquals(h:getLength(), 6)
    for i = 0, 6, 1 do
        h:onLine(i)
        lu.assertEquals(h:current(), i)
    end
    lu.assertEquals(format(h:getLines(10)),'1;2;3;4;5;6')
end
function TestRecorder()
    local h = history.new(5)
    local recorder=h:createRecorder()
    local execed=false
    function exec()
        execed=true
    end
    lu.assertEquals(recorder:getLength(),0)
    lu.assertEquals(recorder:getCap(),0)
    lu.assertEquals(recorder:running(),false)
    lu.assertEquals(format(recorder:getLines()),'')
    h:onLine(1)
    lu.assertEquals(format(recorder:getLines()),'')
    recorder:start(1,exec)
    h:onLine(1)
    lu.assertEquals(format(recorder:getLines()),'1')
    lu.assertEquals(execed,true)
    execed=false
    h:onLine(1)
    lu.assertEquals(format(recorder:getLines()),'1')
    lu.assertEquals(execed,false)
end
os.exit(lu.LuaUnit.run())
