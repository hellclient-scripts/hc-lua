local lu = dofile('../../src/hclua/vendor/luaunit/luaunit.lua')
local eventbus = dofile('../../src/hclua/lib/eventbus/eventbus.lua')

function Test()
    local data_1=0
    local data_2=0
    local function handler1(i)
        data_1=data_1+i
    end
    local function handler2(i)
        data_2=data_2+i
    end
    local e=eventbus.new()
    -- 未注册事件测试
    e:raiseEvent('not_exists')
    -- 正常绑定
    e:bindEvent('a',handler1)
    e:bindEvent('a',handler2)
    e:raiseEvent('a',1)

    lu.assertEquals(data_1,1)
    lu.assertEquals(data_2,1)
    -- 不同事件无干扰
    e:bindEvent('b',handler1)
    e:raiseEvent('a',1)
    lu.assertEquals(data_1,2)
    lu.assertEquals(data_2,2)
    -- 重复绑定
    e:bindEvent('a',handler1)
    e:raiseEvent('a',1)
    lu.assertEquals(data_1,4)
    lu.assertEquals(data_2,3)
    -- 解绑无效处理函数
    e:unbindEvent('not_exists',handler1)
    e:raiseEvent('a',1)
    lu.assertEquals(data_1,6)
    lu.assertEquals(data_2,4)
    -- 解绑正常绑定函数
    e:unbindEvent('a',handler2)
    e:raiseEvent('a',1)
    lu.assertEquals(data_1,8)
    lu.assertEquals(data_2,4)
    -- 解绑重复绑定的函数
    e:unbindEvent('a',handler1)
    e:raiseEvent('a',1)
    lu.assertEquals(data_1,8)
    lu.assertEquals(data_2,4)
    -- 其他事件不受干扰
    e:raiseEvent('b',1)
    lu.assertEquals(data_1,9)
    lu.assertEquals(data_2,4)
    -- 解绑全部事件
    e:bindEvent('a',handler1)
    e:bindEvent('a',handler2)
    e:unbindAll('a')
    e:raiseEvent('a',1)
    lu.assertEquals(data_1,9)
    lu.assertEquals(data_2,4) 
    e:raiseEvent('b',1)
    lu.assertEquals(data_1,10)
    lu.assertEquals(data_2,4)
    -- 解绑不存在的事件的全部处理函数
    e:unbindAll('not_exists')
    e:raiseEvent('a',1)
    e:raiseEvent('b',1)
    lu.assertEquals(data_1,11)
    lu.assertEquals(data_2,4)
    -- 全部重置
    e:reset()
    e:raiseEvent('a',1)
    e:raiseEvent('b',1)
    lu.assertEquals(data_1,11)
    lu.assertEquals(data_2,4)
    -- 解绑无效处理函数
    e:bindEvent('a',handler1)
    e:unbindEvent('a',function ()
    end)
    e:raiseEvent('a',1)
    lu.assertEquals(data_1,12)
    lu.assertEquals(data_2,4)
end
function TestForward()
    local result=''
    local e=eventbus.new()
    local function handler1(data)
        result=result..'.a.'..data
    end
    local function forward1(event,data)
        result=result..'.c.'..event..'.'..data
    end
    local function forward2(event,data)
        result=result..'.d.'..event..'.'..data
    end
    e:bindEvent('A',handler1)
    e:bindForward(forward1)
    e:bindForward(forward2)
    e:raiseEvent('A',1)
    lu.assertEquals(result,'.a.1.c.A.1.d.A.1')
    result=''
    e:raiseEvent('not exists',1)
    lu.assertEquals(result,'.c.not exists.1.d.not exists.1')
    result=''
    e:unbindForward(forward1)
    e:raiseEvent('A',1)
    lu.assertEquals(result,'.a.1.d.A.1')

end
os.exit(lu.LuaUnit.run())
