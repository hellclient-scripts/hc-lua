# 辅助函数

在Hclua.utils里提供了一些可能会使用到的辅助函数，帮助更好的写机器人

## Hclua.util.json

json是引入了 https://github.com/rxi/json.lua 包

方便进行json的处理。

具体API参考官网文档。

最常用的用法为

```lua
local jsonEncoded=Hclua.utils.json.encode(data)

local jsonDecoded=Hclua.utils.json.decode(rawjson)
```