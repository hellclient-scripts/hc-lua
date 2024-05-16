# line 行信息库

本库的作用是将不同Mud客户端触发接受到的行信息(文字触发及相关样式)进行抽象化，方便进行独立于客户端的脚本处理。

## 行信息标准

* 一个行代表一串带样式的文字
* 行信息来源应该为Mud客户端匹配的一行服务器文字
* 正常情况下，行信息不应该包含换行符号
* 行的内容包括 Text(行正文)和Words(词列表)
* Words词列表指将原始服务器文字，按样式不同(而非ansi指令)进行分割，按原始顺序排序
* Text行正文等于所有Words中的词的正文的拼接
* 每个Word词包含如下属性:Text文本,Color色彩,Backgroud背景,Bold加粗,Underlined下划线,Blinking闪烁,Inverse反色
* Word词的Text指一段样式对应的文本。
* Word词的Color和Backgroud都是字符串，分为标准色和RGB色
* 标准色为''[默认],'Black'[黑色],'Red'[红色],'Green'[绿色],'Yellow'[黄色],'Blue'[蓝色],'Magenta'[紫色],'Cyan'[青色],'White'[白色],'BrightBlack'[浅黑],'BrightRed'[浅红],'BrightGreen'[浅绿],'BrightYellow'[浅黄],'BrightBlue'[浅蓝],'BrightMagenta'[浅紫],'BrightCyan'[浅青],'BrightWhite'[浅白]
* 标准色一般根据客户端实现来取值，如有冲突，按上一条的顺序进行优先匹配。色彩和背景色的默认一般指客户端设置的不同的颜色
* RGB色为以#开头，6位大写16进制数，如'#CCCCCC'
* Bold加粗指ansi控制符1的效果,具体取决于客户端实现，值为布尔值
* Underline下划线指ansi控制符4的效果,具体取决于客户端实现，值为布尔值
* Blink闪烁指ansi控制符5,6或3的效果,具体取决于客户端实现，值为布尔值
* Inverse反色指ansi控制符7的效果,具体取决于客户端实现，值为布尔值

## 行信息短描述

行信息短描述是一种将带样式的行信息格式化为紧凑，易识别，易保存，易维护，能直接比较的格式.

范例如下

```
#0AA0标准色文字#1CCCCCCCCCCCC1纯RGB色加粗文字#1CCCCCC*A5RGB色标准背景闪烁加粗文字#1*ACCCCCCE标准色RGB背景加粗下划线闪烁反色文字
```

具体格式如下

* 短描述分为样式和正文部分，样式部分在正文部分之前
* 样式部分以#号开始，正文中所有的#都转义为##
* 短描述样式部分为#开头，后接版本数0或1
* #0为标准色模式样式，格式为#0AA0，第3为字母A开始的色彩序号，第4为字母A开始的背景色序号，第5位为16进制数表示的样式
* #1为RGB模式样式，格式为#1CCCCCCCCCCCCC0,#1\*ACCCCCC0,#1CCCCCC\*A0 格式。第三位开始为色彩表号，\*开头表示后一位为字母A开始的色彩序号，否者之后6位为大写16进制色彩。最后一位为16进制数表示的样式
* 16进制数表示的样式为2进制标志位，其中Bold为1位，Underline为2位，Blinking为4位，Inverse为8位
* 多个词的短描述可以直接作为字符串拼接，以#作为标志分割
## API接口

### 创建行对象

```lua
local line=require('line')
local li=line.Line:new()

print(li.Text) --行对象的文字，自动维护
print(#li.Words) --行对象的词列表,一个数组
```
### 解析短描述

将给定的短描述文字转换为行对象。如果传入的文字无效，则返回nil

```lua
local lineparsed=line.parseLine('#0AA0测试数据')
```

### 行对象追加词

将给定的词追加到行内。

会更新行的Text，平将追加到行的Words内

如果词的样式和Words内最后一个词的样式一致，将与Words的最后一个词合并，不会出现连续两个相同样式的词。

返回值为行本身方便链式调用
```lua
li:appendWord(word1):appendWord(word2)
```
### 行对象转短描述

将给定的行对象转换为短描述字符串

等效于将行对象的Words分别做短描述并直接做字符串拼接。

```lua
local lineshort=li:toShort()
```

### 行对象切片操作

将行对象从指定开始位置，切割指定长度的切片(行信息)

开始位置和长度默认为1,都是字节长度

如果开始位置和长度小于1,则返回nil

如果开始位置大于行对象长度，则返回空行

如果结束位置(开始位置+长度)超过行长度，则以行长度作为结束位置。

```lua
local lineFrom3To5=li:slice(3,3)
```

### 创建词对象

词对象为一串具有相同样式的文字

```lua
local word=line.Word:new()

print(word.Text) --词对象对应文字，字符串，可以手动维护
print(word.Color) --词对象的前景色，字符串
print(word.Backgroud) --词对象的背景色，字符串
print(word.Bold==true) --词对象是否粗体，布尔值
print(word.Underlined==true) --词对象是否下划线，布尔值
print(word.Blinking==true) --词对象是否闪烁，布尔值
print(word.Inverse==true) --词对象是否反色，布尔值
```

### 词对象获取样式描述

获取词对象的样式描述，即短描述中不包含正文的部分。

可以用来做样式比较

```lua
local style=word:getShortStyle() --#0AA0
```

### 词对象转短描述

将词对象转为短描述

```lua
local wordShort=word:toShort() -- #0AA0xxxx
```

### 词对象复制样式

复制词对象的样式并创建新词

传入参数为字符串，新词对象的正文

```lua
local newWord=word:copyStyle('NewText')
print(newWord:getShortStyle()==word:getShortStyle())
```