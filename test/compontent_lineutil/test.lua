local lu = dofile('../../src/hclua/vendor/luaunit/luaunit.lua')
local runtime = dofile('../../src/hclua/runtime/runtime.lua')
runtime.Path = '../../src/hclua/'
local rt = runtime.Runtime:new()
local lineutils = rt:requireModule('compontent/lineutils/lineutils.lua')
local line = rt:requireModule('lib/line/line.lua')

function TestUTF8()
    local str = "你好lua"
    local u8str = lineutils.utf8(str)
    lu.assertEquals(#u8str, 5)
    lu.assertEquals(u8str[1], 3)
    lu.assertEquals(u8str.rawstring:sub(0, 3), '你')
    lu.assertEquals(u8str[2], 6)
    lu.assertEquals(u8str.rawstring:sub(4, 6), '好')
    lu.assertEquals(u8str[3], 7)
    lu.assertEquals(u8str.rawstring:sub(7, 7), 'l')
    lu.assertEquals(u8str[4], 8)
    lu.assertEquals(u8str.rawstring:sub(8, 8), 'u')
    lu.assertEquals(u8str[5], 9)
    lu.assertEquals(u8str.rawstring:sub(9, 9), 'a')
end

function TestMono()
    local li = line.Line:new()
    local word = line.Word:new()
    word.Text = 'a测b试'
    word.Color = 'Red'
    local word2 = line.Word:new()
    word2.Text = '你好lua'
    word2.Color = 'Green'
    li:appendWord(word):appendWord(word2)
    -- 默认值
    local result = lineutils.UTF8Mono(li)
    lu.assertEquals(result:toShort(), word:copyStyle('a'):toShort())
    result = lineutils.UTF8Mono(li, 1, 1)
    lu.assertEquals(result:toShort(), word:copyStyle('a'):toShort())
    result = lineutils.UTF8Mono(li, 2)
    lu.assertEquals(result:toShort(), word:copyStyle('测'):toShort())
    result = lineutils.UTF8Mono(li, 2, 2)
    lu.assertEquals(result:toShort(), word:copyStyle('测'):toShort())
    result = lineutils.UTF8Mono(li, 0)
    lu.assertEquals(result, nil)
    result = lineutils.UTF8Mono(li, 1, 0)
    lu.assertEquals(result, nil)
    -- 长度不足
    result = lineutils.UTF8Mono(li, 2, 1)
    lu.assertEquals(result:toShort(), word:copyStyle('测'):toShort())
    result = lineutils.UTF8Mono(li, 3, 1)
    lu.assertEquals(result:toShort(), word:copyStyle('测'):toShort())
    -- 跨字
    result = lineutils.UTF8Mono(li, 3, 3)
    lu.assertEquals(result:toShort(), word:copyStyle('测b试'):toShort())
    result = lineutils.UTF8Mono(li, 2, 5)
    lu.assertEquals(result:toShort(), word:copyStyle('测b试'):toShort())
    -- 跨word
    result = lineutils.UTF8Mono(li, 3, 5)
    lu.assertEquals(result:toShort(), word:copyStyle('测b试'):toShort() .. word2:copyStyle('你'):toShort())
    result = lineutils.UTF8Mono(li, 2, 6)
    lu.assertEquals(result:toShort(), word:copyStyle('测b试'):toShort() .. word2:copyStyle('你'):toShort())
    -- 超长
    result = lineutils.UTF8Mono(li, 1, 13)
    lu.assertEquals(result:toShort(), word:toShort() .. word2:toShort())
    result = lineutils.UTF8Mono(li, 1, 33)
    lu.assertEquals(result:toShort(), word:toShort() .. word2:toShort())
    result = lineutils.UTF8Mono(li, 7, 33)
    lu.assertEquals(result:toShort(), word2:toShort())
    result = lineutils.UTF8Mono(li, 33, 33)
    lu.assertEquals(result:toShort(), '')
end

function TestLines()
    local lines = {}
    local li = line.Line:new()
    local word = line.Word:new()
    word.Text = '测试1测试1测试1'
    word.Color = 'Red'
    li:appendWord(word)
    table.insert(lines, li)
    local li2 = line.Line:new()

    local word2 = line.Word:new()
    word2.Text = '测试2测试2'
    word2.Color = 'Green'
    li2:appendWord(word2)
    table.insert(lines, li2)
    local li3 = line.Line:new()
    local word3 = line.Word:new()
    word3.Text = '测试3'
    word3.Color = 'Yellow'
    li3:appendWord(word3)
    table.insert(lines, li3)
    lu.assertEquals(lineutils.combineLines(lines, true), word.Text .. word2.Text .. word3.Text)
    lu.assertEquals(lineutils.combineLines(lines), word.Text .. '\n' .. word2.Text .. '\n' .. word3.Text)
    lu.assertEquals(lineutils.combineLinesShort(lines, true), word:toShort() .. word2:toShort() .. word3:toShort())
    lu.assertEquals(lineutils.combineLinesShort(lines), word:toShort() .. '\n' .. word2:toShort() ..'\n' .. word3:toShort())

    lu.assertEquals(lineutils.sliceLines(lines,0,1),nil)
    lu.assertEquals(lineutils.sliceLines(lines,1,0),nil)
    lu.assertEquals(lineutils.combineLinesShort(lineutils.sliceLines(lines,7,1)),word:copyStyle('1'):toShort()..'\n'..word2:copyStyle('2'):toShort()..'\n'..word3:copyStyle('3'):toShort())
    lu.assertEquals(lineutils.combineLinesShort(lineutils.sliceLines(lines,1,7)),word:copyStyle('测试1'):toShort()..'\n'..word2:copyStyle('测试2'):toShort()..'\n'..word3:copyStyle('测试3'):toShort())
    lu.assertEquals(lineutils.combineLinesShort(lineutils.sliceLines(lines,1,7,2)),word:copyStyle('测试1'):toShort()..'\n'..word2:copyStyle('测试2'):toShort())
    lu.assertEquals(lineutils.combineLinesShort(lineutils.sliceLines(lines,1,14)),word:copyStyle('测试1测试1'):toShort()..'\n'..word2:copyStyle('测试2测试2'):toShort()..'\n'..word3:copyStyle('测试3'):toShort())
    lu.assertEquals(lineutils.combineLinesShort(lineutils.sliceLines(lines,8,7)),word:copyStyle('测试1'):toShort()..'\n'..word2:copyStyle('测试2'):toShort()..'\n'..'')

    lu.assertEquals(lineutils.linesUTF8Mono(lines,0,1),nil)
    lu.assertEquals(lineutils.linesUTF8Mono(lines,1,0),nil)
    lu.assertEquals(lineutils.combineLinesShort(lineutils.linesUTF8Mono(lines,5,1)),word:copyStyle('1'):toShort()..'\n'..word2:copyStyle('2'):toShort()..'\n'..word3:copyStyle('3'):toShort())
    lu.assertEquals(lineutils.combineLinesShort(lineutils.linesUTF8Mono(lines,1,5)),word:copyStyle('测试1'):toShort()..'\n'..word2:copyStyle('测试2'):toShort()..'\n'..word3:copyStyle('测试3'):toShort())
    lu.assertEquals(lineutils.combineLinesShort(lineutils.linesUTF8Mono(lines,1,5,2)),word:copyStyle('测试1'):toShort()..'\n'..word2:copyStyle('测试2'):toShort())
    lu.assertEquals(lineutils.combineLinesShort(lineutils.linesUTF8Mono(lines,1,10)),word:copyStyle('测试1测试1'):toShort()..'\n'..word2:copyStyle('测试2测试2'):toShort()..'\n'..word3:copyStyle('测试3'):toShort())
    lu.assertEquals(lineutils.combineLinesShort(lineutils.linesUTF8Mono(lines,6,5)),word:copyStyle('测试1'):toShort()..'\n'..word2:copyStyle('测试2'):toShort()..'\n'..'')
end

os.exit(lu.LuaUnit.run())
