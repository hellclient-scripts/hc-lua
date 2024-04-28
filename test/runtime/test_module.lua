local m={}
m.count=m.count or 0
m.count= m.count+1
function m.method(input)
    return input..'ok'
end
return m