local lu = dofile('../../src/hclua/vendor/luaunit/luaunit.lua')
local runtime=dofile('../../src/hclua/runtime/runtime.lua')
runtime.path='../../src/hclua/'
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
function TestCopy()
    local word=line.Word:new()
    word.Bold=true
    word.Underlined=true
    word.Blinking=true
    word.Inverse=true
    word.Color='Red'
    word.Text='text'
    local word2=word:copyStyle()
    lu.assertEquals(word2.Text,'')
    lu.assertEquals(word2:getShortStyle(),word:getShortStyle())
    local word3=word:copyStyle('test3')
    lu.assertEquals(word3.Text,'test3')
    lu.assertEquals(word3:getShortStyle(),word:getShortStyle())
end

function TestSlice()
    local li=line.Line:new()
    local li2
    local word=line.Word:new()
    word.Text='a'
    word.Color='Red'
    local word2=line.Word:new()
    word2.Text='bc'
    word2.Color='Green'
    local word3=line.Word:new()
    word3.Text='def'
    word3.Color='Blue'
    local word4=line.Word:new()
    word4.Text='ghij'
    word4.Color='White'
    li:appendWord(word)
    :appendWord(word2)
    :appendWord(word3)
    :appendWord(word4)
    -- 无效参数
    li2=li:slice(0)
    lu.assertEquals(li2,nil)
    li2=li:slice(1,0)
    lu.assertEquals(li2,nil)
    -- 默认擦数
    li2=li:slice()
    lu.assertEquals(li2:toShort(),word:copyStyle('a'):toShort())
    li2=li:slice(1,1)
    lu.assertEquals(li2:toShort(),word:copyStyle('a'):toShort())
    li2=li:slice(2)
    lu.assertEquals(li2:toShort(),word2:copyStyle('b'):toShort())
    li2=li:slice(2,1)
    lu.assertEquals(li2:toShort(),word2:copyStyle('b'):toShort())
    -- 超长
    li2=li:slice(1,99)
    lu.assertEquals(li2:toShort(),li:toShort())
    li2=li:slice(1,#li.Text)
    lu.assertEquals(li2:toShort(),li:toShort())
    li2=li:slice(2,99)
    lu.assertEquals(word:toShort()..li2:toShort(),li:toShort())
    li2=li:slice(5,99)
    lu.assertEquals(li2:toShort(),word3:copyStyle('ef'):toShort()..word4:toShort())

    -- 开头切到正好
    li2=li:slice(1,3)
    lu.assertEquals(li2:toShort(),word:toShort()..word2:toShort())
    -- 开头切到当中
    li2=li:slice(1,4)
    lu.assertEquals(li2:toShort(),word:toShort()..word2:toShort()..word3:copyStyle('d'):toShort())    
    --正好切到正好
    li2=li:slice(2,5)
    lu.assertEquals(li2:toShort(),word2:toShort()..word3:toShort())
    --正好到当中
    li2=li:slice(2,7)
    lu.assertEquals(li2:toShort(),word2:toShort()..word3:toShort()..word4:copyStyle('gh'):toShort())
    -- 正好到结尾
    li2=li:slice(2,#li.Text-1)
    lu.assertEquals(li2:toShort(),word2:toShort()..word3:toShort()..word4:toShort())
    -- 当中到正好
    li2=li:slice(3,4)
    lu.assertEquals(li2:toShort(),word2:copyStyle('c'):toShort()..word3:toShort())
    -- 当中到当中
    li2=li:slice(3,3)
    lu.assertEquals(li2:toShort(),word2:copyStyle('c'):toShort()..word3:copyStyle('de'):toShort())
    -- 当中到结尾
    li2=li:slice(3,#li.Text-2)
    lu.assertEquals(li2:toShort(),word2:copyStyle('c'):toShort()..word3:toShort()..word4:toShort())
    -- 部分截取
    li2=li:slice(8,2)
    lu.assertEquals(li2:toShort(),word4:copyStyle('hi'):toShort())
    
end
-- 测试同样式单词合并
function TestAppend()
    local li=line.Line:new()
    local word=line.Word:new()
    word.Text='a'
    word.Color='Red'
    local word2=line.Word:new()
    word2.Text='b'
    word2.Color='Green'
    word2.Bold=true
    local word3=word2:copyStyle('c')
    li:appendWord(word):appendWord(word2):appendWord(word3)
    lu.assertEquals(li.Text,'abc')
    lu.assertEquals(#li.Words,2)
    lu.assertEquals(li.Words[1]:toShort(),word:toShort())
    lu.assertEquals(li.Words[2].Text,'bc')
    lu.assertEquals(li.Words[2]:getShortStyle(),word2:getShortStyle())
end
function TestShortColor()
    local word=line.Word:new()
    word.Text='a'
    word.Color='Red'
    word.Background='Green'
    word.Bold=true
    local short=word:toShort()
    lu.assertEquals(string.sub(short,1,1),'#')
    lu.assertEquals(string.sub(short,2,2),'0')
    local wordparsed=line.parseLine(short).Words[1]
    lu.assertEquals(word.Text,wordparsed.Text)
    lu.assertEquals(word.Color,wordparsed.Color)
    lu.assertEquals(word.Background,wordparsed.Background)
    lu.assertEquals(word.Bold,wordparsed.Bold)

    word=line.Word:new()
    word.Text='a'
    word.Color='#333333'
    word.Background='Green'
    word.Bold=true
    short=word:toShort()
    lu.assertEquals(string.sub(short,1,1),'#')
    lu.assertEquals(string.sub(short,2,2),'1')
    wordparsed=line.parseLine(short).Words[1]
    lu.assertEquals(word.Text,wordparsed.Text)
    lu.assertEquals(word.Color,wordparsed.Color)
    lu.assertEquals(word.Background,wordparsed.Background)
    lu.assertEquals(word.Bold,wordparsed.Bold)

    word=line.Word:new()
    word.Text='a'
    word.Color='Red'
    word.Background='#666666'
    word.Bold=true
    short=word:toShort()
    lu.assertEquals(string.sub(short,1,1),'#')
    lu.assertEquals(string.sub(short,2,2),'1')
    wordparsed=line.parseLine(short).Words[1]
    lu.assertEquals(word.Text,wordparsed.Text)
    lu.assertEquals(word.Color,wordparsed.Color)
    lu.assertEquals(word.Background,wordparsed.Background)
    lu.assertEquals(word.Bold,wordparsed.Bold)

    word=line.Word:new()
    word.Text='a'
    word.Color='#333333'
    word.Background='#666666'
    word.Bold=true
    short=word:toShort()
    lu.assertEquals(string.sub(short,1,1),'#')
    lu.assertEquals(string.sub(short,2,2),'1')
    wordparsed=line.parseLine(short).Words[1]
    lu.assertEquals(word.Text,wordparsed.Text)
    lu.assertEquals(word.Color,wordparsed.Color)
    lu.assertEquals(word.Background,wordparsed.Background)
    lu.assertEquals(word.Bold,wordparsed.Bold)
end
os.exit( lu.LuaUnit.run() )
