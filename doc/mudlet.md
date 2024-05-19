# 使用UTF8编码Mudlet安装HCLua
# 安装步骤
## 解压代码
将代码解压缩后，src中的hclua目录复制到对应的profile目录下
## 设置加载代码
新建一个名为hclualoader的script

将代码解压缩后的loader/mudlet.lua文件复制该script里，并在你的主脚本的合适位置引用。

在script里，可以通过注释Hclua:loadModules中的条目，屏蔽某些模块的加载

## 客户端调整
在处理器设置界面，将hclua.online拖到所有其他触发器上方

在'首选项'>'颜色视图'中，确保前景色和白色一致，背景色和黑色一致


# 副作用
* 脚本会添加一个名为hclua.online，触发为^.*$为1的触发器
* 脚本会添加间隔为0.1秒的临时触发器
* lua全局空间会添加一个hclua表，里面是HCLua的所有相关代码
* readUserFile和writeUserFile会操作profile文件夹下，以.user.xxx开头的文件，比如c:\modlet\profiles\xxx读写的data.txt就是 c:\modlet\profiles\xxx\user.data.txt