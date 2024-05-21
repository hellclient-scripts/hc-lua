# 使用GBK编码的Mushclient安装HCLua
## 安装步骤
### 解压代码
将代码解压缩后，src中的hclua目录复制到mcl文件夹下
### 设置加载代码
将代码解压缩后的loader/mush.lua文件复制到mcl文件夹下，并在你的主脚本的合适位置引用。

在mush.lua文件中，可以通过注释Hclua:loadModules中的条目，屏蔽某些模块的加载

### 客户端调整

在你脚本的设置(ctrl+shift+6)的Connect和Disconnect事件指定的回调函数中，分别调用 Hclua.world.params.on_connect 和 Hclua.world.params.on_disconnect函数。


## 副作用
* 脚本会添加一个名为hclua_trigger，触发为^.*$，优先级为1的触发器
* 脚本会添加一个名为hclua_timer，间隔为0.1秒的触发器
* lua全局空间会添加一个hclua表，里面是HCLua的所有相关代码
* lua的package.path会添加mcl所在目录(GetInfo(67) .. "/?.lua")
* readUserFile和writeUserFile会操作mcl文件夹下，以mcl全名.user.xxx开头的文件，比如c:\mcl\world.mcl读写的data.txt就是 c:\mcl\world.mcl.user.data.txt


## 下一步

[定制Hclua](customize.md)