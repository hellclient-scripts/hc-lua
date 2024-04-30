local lu = dofile('../../src/hclua/vendor/luaunit/luaunit.lua')
local runtime=dofile('../../src/hclua/runtime/runtime.lua')
runtime.Path='../../src/hclua/'
local rt=runtime.Runtime:new()
local line=rt:requireModule('lib/line/line.lua')
function TestLine()
    local li=line.Line:new()
    local word=line.Word:new()
    word.Text='test'
    word.Color='Red'
    local short=word:toShort()
    local word2=line.Word:new()
    word2.Text='test2'
    word2.Color='Green'
    local short2=word2:toShort()
    li:appendWord(word):appendWord(word2)
    lu.assertEquals(li.Text,'testtest2')
    lu.assertEquals(li:toShort(),short..short2)
    
end
function TestParse()
    local word=line.Word:new()
    word.Text='test'
    local li=line.Line:new()
    li:appendWord(word)
    local li2=line.parseLine(li:toShort())
    lu.assertEquals(#li2.Words,1)
    lu.assertEquals(li2.Words[1].Text,word.Text)
    -- 样式
    word=line.Word:new()
    lu.assertNotIsTrue(line.parseLine(word:toShort())==nil)
    lu.assertEquals(line.parseLine(word:toShort()).Words[1].Bold,false)
    lu.assertEquals(line.parseLine(word:toShort()).Words[1].Underlined,false)
    lu.assertEquals(line.parseLine(word:toShort()).Words[1].Blinking,false)
    lu.assertEquals(line.parseLine(word:toShort()).Words[1].Inverse,false)
    word.Bold=true
    lu.assertEquals(line.parseLine(word:toShort()).Words[1].Bold,true)
    word.Underlined=true
    lu.assertEquals(line.parseLine(word:toShort()).Words[1].Underlined,true)
    word.Blinking=true
    lu.assertEquals(line.parseLine(word:toShort()).Words[1].Blinking,true)
    word.Inverse=true
    lu.assertEquals(line.parseLine(word:toShort()).Words[1].Inverse,true)

    -- 转义
    word=line.Word:new()
    word.Text='#test##'
    li=line.Line:new():appendWord(word)
    lu.assertEquals(word:toShort(),li:toShort())
    li2=line.parseLine(li:toShort())
    lu.assertEquals(li2.Words[1].Text,word.Text)
    -- 无效
    lu.assertEquals(line.parseLine('#3'),nil)
    lu.assertEquals(line.parseLine('#01'),nil)
    lu.assertEquals(line.parseLine('#1xxxxxx'),nil)
    lu.assertEquals(line.parseLine('###'),nil)
    lu.assertEquals(line.parseLine('abc'),nil)
    lu.assertEquals(line.parseLine('#0AA0a#'),nil)
end
function TestShort()
    local word=line.Word:new()
    local word2=line.Word:new()
    word.Bold=true
    word.Color='Red'
    word.Text='text'
    word2.Bold=true
    word2.Color='Red'
    word2.Text='text2'
    lu.assertEquals(word:getShortStyle(),word2:getShortStyle())
    word2.Inverse=true
    lu.assertNotIsTrue(word:getShortStyle(),word2:getShortStyle())
end
os.exit( lu.LuaUnit.run() )
