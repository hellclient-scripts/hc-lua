local lu = dofile('../../src/hclua/vendor/luaunit/luaunit.lua')
local commands = dofile('../../src/hclua/lib/commands/commands.lua')

function TestCommands()
    local old = false
    local new = false
    local fn = function(data)
        return 'fn.' .. data
    end
    local fnnew = function()
        new = true
    end
    local fnold = function()
        old = true
    end
    local defaultfn = function(id,data)
        return 'default.' .. id..'.'..data
    end
    local c = commands.new(defaultfn)
    lu.assertEquals(c:exec('not exist', 'data'), 'default.not exist.data')
    lu.assertEquals(c:getCommand('not exist'), nil)
    c:register('fn', fn)
    lu.assertEquals(c:exec('fn', 'datafn'), 'fn.datafn')
    lu.assertEquals(c:getCommand('fn'):id(), 'fn')
    c:register('dup', fnold)
    c:register('dup', fnnew)
    c:exec('dup')
    lu.assertEquals(old, false)
    lu.assertEquals(new, true)

    local items = c:list()
    lu.assertEquals(#items, 2)
    lu.assertEquals(items[1]:id() .. '-' .. items[2]:id(), 'fn-dup')
    c:remove('not_exists')
    lu.assertEquals(#c:list(), 2)
    c:remove('fn')
    lu.assertEquals(#c:list(), 1)
    lu.assertEquals(c:list()[1]:id(), 'dup')
    lu.assertEquals(c:getCommand('fn'), nil)
    lu.assertEquals(c:exec('fn', 'datafn'), 'default.fn.datafn')

    local cmd=c:register('intro',nil)
    lu.assertEquals(cmd:intro(), '')
    lu.assertEquals(cmd:desc(), '')
    cmd:withIntro('intro')
    lu.assertEquals(cmd:intro(), 'intro')
    lu.assertEquals(cmd:desc(), 'intro')
    cmd:withDesc('desc')
    lu.assertEquals(cmd:intro(), 'intro')
    lu.assertEquals(cmd:desc(), 'desc')
end

os.exit(lu.LuaUnit.run())
