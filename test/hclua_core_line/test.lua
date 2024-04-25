local lu = dofile('../../src/hclua/vendor/luaunit/luaunit.lua')
local runtime=dofile('../../src/hclua/runtime/runtime.lua')
runtime.Path='../../src/hclua/'
local rt=runtime.Runtime:new()
local line=rt:requireModule('core/line/line.lua')
function TestParse()
    local word=line.Word:new()
    word.Text='test'
    local li=line.Line:new()
    li:appendWord(word)
    local li2=line.parseLine(line._json.encode(li))
    lu.assertEquals(#li2.Words,1)
    lu.assertEquals(li2.Words[1].Text,word.Text)
end

os.exit( lu.LuaUnit.run() )
