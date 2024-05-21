local lu = dofile('../../src/hclua/vendor/luaunit/luaunit.lua')
local runtime=dofile('../../src/hclua/runtime/runtime.lua')
runtime.Path='../../src/hclua/'
function TestRuntime()
    runtime.Path='../../src/hclua/'
    local rt=runtime.Runtime:new()
    lu.assertEquals(rt:getCharset(),runtime.DefaultCharset)
    lu.assertEquals(rt:withCharset('utf8'):getCharset(),'utf8')
    lu.assertEquals(rt:getHostType(),runtime.DefaultHostType)
    lu.assertEquals(rt:withHostType('hellclient'):getHostType(),'hellclient')
    lu.assertEquals(rt:loaded('test_module.lua'),false)
    runtime.Path='not::exits::folder'
    lu.assertEquals(rt.getPath(),runtime.Path)
    lu.assertErrorMsgContains('cannot open',function() rt:require('test_module.lua') end)
    runtime.Path=''
    lu.assertEquals(rt.getPath(),runtime.Path)
    lu.assertNotEquals(rt:require('test_module.lua'),nil)
    lu.assertEquals(rt:loaded('test_module.lua'),true)
    lu.assertEquals(rt:require('test_module.lua').count,1)
    lu.assertEquals(rt:require('test_module.lua').method('test'),'testok')
end
function TestUtils()
    runtime.Path='../../src/hclua/'
    local rt=runtime.Runtime:new()
    local jsondata=rt.HC.utils.json.decode(rt.HC.utils.json.encode('data'))
    lu.assertEquals(jsondata,'data')
end
os.exit( lu.LuaUnit.run() )
