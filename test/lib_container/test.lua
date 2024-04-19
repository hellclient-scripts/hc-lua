local lu = dofile('../../src/hclua/vendor/luaunit/luaunit.lua')
local list = dofile('../../src/hclua/lib/container/list.lua')
local ring = dofile('../../src/hclua/lib/container/ring.lua')

local function checkListLen(li, len)
    local n = li:len()
    lu.assertEquals(n, len)
end
local function checkListPointers(li, es)
    local root = li._root
    checkListLen(li, #es)
    if #es == 0 then
        lu.assertNotIsTrue(li._root._next ~= nil and li._root._next ~= root or
            li._root.prev ~= nil and li._root._prev ~= root)
    end
    for i, e in ipairs(es) do
        local prev = root
        local Prev = nil
        if (i > 1) then
            prev = es[i - 1]
            Prev = prev
        end
        lu.assertEquals(e._prev, prev)
        lu.assertEquals(e:prev(), Prev)
        local next = root
        local Next = nil
        if i < #es then
            next = es[i + 1]
            Next = next
        end
        lu.assertEquals(e._next, next)
        lu.assertEquals(e:next(), Next)
    end
end
local function checkList(li, es)
    lu.assertEquals(checkListLen(li, #es))
    local i = 1
    local e = li:front()
    while e ~= nil do
        local le = e:value()
        lu.assertEquals(le, es[i])
        e = e:next()
        i = i + 1
    end
end

function TestList()
    local l = list.new()
    checkListPointers(l, {})
    local e = l:pushFront('a')
    checkListPointers(l, { e })
    l:moveToFront(e)
    checkListPointers(l, { e })
    l:moveToBack(e)
    checkListPointers(l, { e })
    l:remove(e)
    checkListPointers(l, {})

    local e2 = l:pushFront(2)
    local e1 = l:pushFront(1)
    local e3 = l:pushBack(3)
    local e4 = l:pushBack('banana')
    checkListPointers(l, { e1, e2, e3, e4 })
    l:remove(e2)
    checkListPointers(l, { e1, e3, e4 })
    l:moveToFront(e3)
    checkListPointers(l, { e3, e1, e4 })
    l:moveToFront(e1)
    l:moveToBack(e3)
    checkListPointers(l, { e1, e4, e3 })
    l:moveToFront(e3)
    checkListPointers(l, { e3, e1, e4 })
    l:moveToFront(e3)
    checkListPointers(l, { e3, e1, e4 })
    e2 = l:insertBefore(2, e1)
    checkListPointers(l, { e3, e2, e1, e4 })
    l:remove(e2)
    e2 = l:insertBefore(2, e4)
    checkListPointers(l, { e3, e1, e2, e4 })
    l:remove(e2)
    e2 = l:insertBefore(2, e3)
    checkListPointers(l, { e2, e3, e1, e4 })
    l:remove(e2)
    e2 = l:insertAfter(2, e1)
    checkListPointers(l, { e3, e1, e2, e4 })
    l:remove(e2)
    e2 = l:insertAfter(2, e4)
    checkListPointers(l, { e3, e1, e4, e2 })
    l:remove(e2)
    e2 = l:insertAfter(2, e3)
    checkListPointers(l, { e3, e2, e1, e4 })
    l:remove(e2)
    local sum = 0
    e = l:front()
    while e ~= nil do
        local i = tonumber(e:value())
        if (i) then
            sum = sum + i
        end
        e = e:next()
    end
    lu.assertEquals(sum, 4)
    local next
    e = l:front()
    while e ~= nil do
        next = e:next()
        l:remove(e)
        e = next
    end
    checkListPointers(l, {})
end

function TestListExtending()
    local l1 = list.new()
    local l2 = list.new()
    l1:pushBack(1)
    l1:pushBack(2)
    l1:pushBack(3)
    l2:pushBack(4)
    l2:pushBack(5)
    local l3 = list.new()
    l3:pushBackList(l1)
    checkList(l3, { 1, 2, 3 })
    l3:pushBackList(l2)
    checkList(l3, { 1, 2, 3, 4, 5 })
    l3 = list.new()
    l3:pushFrontList(l2)
    checkList(l3, { 4, 5 })
    l3:pushFrontList(l1)
    checkList(l3, { 1, 2, 3, 4, 5 })
    l3 = list.new()
    l3:pushBackList(l1)
    checkList(l3, { 1, 2, 3 })
    l3:pushBackList(l3)
    checkList(l3, { 1, 2, 3, 1, 2, 3 })
    l3 = list.new()
    l3:pushFrontList(l1)
    checkList(l3, { 1, 2, 3 })
    l3:pushFrontList(l3)
    checkList(l3, { 1, 2, 3, 1, 2, 3 })
    l3 = list.new()
    l1:pushBackList(l3)
    checkList(l1, { 1, 2, 3 })
    l1:pushFrontList(l3)
    checkList(l1, { 1, 2, 3 })
end

function TestListRemove()
    local l = list.new()
    local e1 = l:pushBack(1)
    local e2 = l:pushBack(2)
    checkListPointers(l, { e1, e2 })
    local e = l:front()
    l:remove(e)
    checkListPointers(l, { e2 })
    l:remove(e)
    checkListPointers(l, { e2 })
end

function TestListMove()
    local l = list.new()
    local e1 = l:pushBack(1)
    local e2 = l:pushBack(2)
    local e3 = l:pushBack(3)
    local e4 = l:pushBack(4)

    l:moveAfter(e3, e3)
    checkListPointers(l, { e1, e2, e3, e4 })

    l:moveBefore(e2, e2)
    checkListPointers(l, { e1, e2, e3, e4 })

    l:moveAfter(e3, e2)
    checkListPointers(l, { e1, e2, e3, e4 })

    l:moveBefore(e2, e3)
    checkListPointers(l, { e1, e2, e3, e4 })

    l:moveBefore(e2, e4)
    checkListPointers(l, { e1, e3, e2, e4 })
    local e
    e = e2
    e2 = e3
    e3 = e
    l:moveBefore(e4, e1)
    checkListPointers(l, { e4, e1, e2, e3 })

    e = e1
    e1 = e4
    e4 = e3
    e3 = e2
    e2 = e

    l:moveAfter(e4, e1)
    checkListPointers(l, { e1, e4, e2, e3 })

    e = e2
    e2 = e4
    e4 = e3
    e3 = e
    l:moveAfter(e2, e3)
    checkListPointers(l, { e1, e3, e2, e4 })
end

function TestListInsertBeforeUnknownMark()
    local l = list.new()
    l:pushBack(1)
    l:pushBack(2)
    l:pushBack(3)
    l:insertBefore(1, list.ListItem:new())
    checkList(l, { 1, 2, 3 })
end

function TestListInsertAfterUnknownMark()
    local l = list.new()
    l:pushBack(1)
    l:pushBack(2)
    l:pushBack(3)
    l:insertAfter(1, list.ListItem:new())
    checkList(l, { 1, 2, 3 })
end

function TestListMoveUnknownMark()
    local l1 = list.new()
    local e1 = l1:pushBack(1)

    local l2 = list.new()
    local e2 = l2:pushBack(2)
    l1:moveAfter(e1, e2)
    checkList(l1, { 1 })
    checkList(l2, { 2 })
    l1:moveBefore(e1, e2)
    checkList(l1, { 1 })
    checkList(l2, { 2 })
end

local function verify(r, N, sum)
    if r == nil then
        lu.assertEquals(0, N)
        return
    end
    local n = r:len()
    lu.assertEquals(n, N)
    n = 0
    local s = 0
    r:apply(function(p)
        n = n + 1
        if (p ~= nil) then
            s = s + p
        end
    end)
    lu.assertEquals(n, N)
    lu.assertNotIsTrue(sum >= 0 and s ~= sum)
    if r == nil then
        return
    end
    if r._next ~= nil then
        local p
        local q = r
        while p == nil or q ~= r do
            lu.assertNotIsTrue(p ~= nil and p ~= q:prev())
            p = q
            q = q:next()
        end
        lu.assertNotIsTrue(p ~= r:prev())
    end
    lu.assertNotIsTrue(r:next() ~= r._next)
    lu.assertNotIsTrue(r:prev() ~= r._prev)
    lu.assertNotIsTrue(r:move(0) ~= r)
    for i = 0, 9, 1 do
        local ni = N + i
        local mi = ni % n
        lu.assertNotIsTrue(r:move(ni) ~= r:move(mi))
        lu.assertNotIsTrue(r:move(-ni) ~= r:move(-mi))
    end
end
local function makeN(n)
    local r = ring.new(n)
    local i = 1
    while i <= n do
        r:withValue(i)
        i = i + 1
        r = r:next()
    end
    return r
end
local function sumN(n)
    return (n * n + n) / 2
end
function TestRingNew()
    local i = 0
    while i < 10 do
        local r = ring.new(i)
        verify(r, i, -1)
        i = i + 1
    end
    i = 0
    while i < 10 do
        local r = makeN(i)
        verify(r, i, sumN(i))
        i = i + 1
    end
end

function TestRingLink1()
    local r1a = makeN(1)
    local r1b = ring.new(1)
    local r2a = r1a:link(r1b)
    verify(r2a, 2, 1)
    lu.assertNotIsTrue(r2a ~= r1a)
    local r2b = r2a:link(r2a:next())
    verify(r2b, 2, 1)
    lu.assertNotIsTrue(r2b ~= r2a:next())
    local r1c = r2b:link(r2b)
    verify(r1c, 1, 1)
    verify(r2b, 1, 0)
end

function TestRingLink2()
    local r0
    local r1a = ring.Ring:new():withValue(42)
    local r1b = ring.Ring:new():withValue(77)
    local r10 = makeN(10)
    r1a:link(r0)
    verify(r1a, 1, 42)
    r1a:link(r1b)
    verify(r1a, 2, 42 + 77)
    r10:link(r0)
    verify(r10, 10, sumN(10))
    r10:link(r1a)
    verify(r10, 12, sumN(10) + 42 + 77)
end

function TestRingLink3()
    local r = ring.Ring:new()
    local n = 1
    local i = 1
    while i < 10 do
        n = n + i
        verify(r:link(ring.new(i)), n, -1)
        i = i + 1
    end
end

function TestRingUnlink()
    local r10 = makeN(10)
    local s10 = r10:move(6)
    local sum10 = sumN(10)
    verify(r10, 10, sum10)
    verify(s10, 10, sum10)

    local r0 = r10:unlink(0)
    verify(r0, 0, 0)

    local r1 = r10:unlink(1)
    verify(r1, 1, 2)
    verify(r10, 9, sum10 - 2)

    local r9 = r10:unlink(9)
    verify(r9, 9, sum10 - 2)
    verify(r10, 9, sum10 - 2)
end

function TestRingtLinkUnlink()
    local i=1
    while i<4 do
        local ri=ring.new(i)
        local j=0
        while j<i do
            local rj=ri:unlink(j)
            verify(rj,j,-1)
            verify(ri,i-j,-1)
            ri:link(rj)
            verify(ri,i,-1)
            j=j+1
        end
        i=i+1
    end
end

function TestRingMoveEmptyRing()
    local r=ring.Ring:new()
    r:move(1)
    verify(r,1,0)
end

os.exit(lu.LuaUnit.run())
