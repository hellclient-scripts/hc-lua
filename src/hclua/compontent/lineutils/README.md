# lineutils 行信息工具组件

行信息工具组件提供了常用的行信息辅助函数。

# lineutils 合并行信息数组文本

将给到的行信息数组的正文合并为一个字符串

默认用换行分割，第二个参数为true则不加入换行直接合并

```lua
    print(lineutils.combineLines(lines,false))
```

# lineutils 合并行信息数组短描述

将给到的行信息数组的短描述合并为一个字符串

默认用换行分割，第二个参数为true则不加入换行直接合并

```lua
    print(lineutils.combineLinesShort(lines,false))
```


# lineutils utf8显示宽切片

将给定的行按utf8显示宽进行切片。

utf8显示宽指ascii字符计为宽度1,非ascii记为宽度2。

如果切片时，切片点在字符中央，则整个字符都将被并入结果

第一个参数是待切片的字符串，第二个参数是切片开始的位置，第三个参数为切片长度

切片和长度都必须为正整数,否则返回nil

```lua
    local newline=lineutiles.UTF8Mono(line,3,4) --按显示宽度裁切第3-6位信息(第2-3个中文位置)
```


# lineutils 切片行信息数组

将给定的行信息数组进行切片，即统一按开始位置和长度切除新的矩形信息。

第一个参数为行信息数组

第二个参数为切片的开始位置，应该为正整数

第三个参数为切片的长途，应该为正整数

第四个参数为最大行数。默热是保留所有行。

返回值为新的行信息数组。

如果开始位置或长度无效，则返回空

```lua
local newlines=lineutils.sliceLines(lines,3,6,10)
```

# lineutils utf8显示宽切片行信息数组

将给定的行信息数组进行utf8显示宽切片,utf8显示宽的批量版本。

第一个参数为行信息数组

第二个参数为切片的开始位置，应该为正整数

第三个参数为切片的长途，应该为正整数

第四个参数为最大行数。默热是保留所有行。

返回值为新的行信息数组。

如果开始位置或长度无效，则返回空

```lua
local newlines=lineutils.linesUTF8Mono(lines,3,6,10)
```