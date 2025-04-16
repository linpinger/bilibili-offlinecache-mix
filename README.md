# bilibili-offlinecache-mix
bilibili(B站)android离线缓存导出并合成音视频及弹幕为MKV

- **缘起:** 两手机，里面的离线缓存分别有 57G 和 30G，感觉存储空间有点吃紧，就想把它导出来

# 解决办法:

- 现成的app: <https://github.com/10miaomiao/bili-down-out> ，它使用 `shizuku` 来获得 adb权限，就可以读取 `/sdcard/Android/data/tv.danmaku.bili/download/` 目录，不过不好自定义导出文件名，给作者发消息，ta说不想更新这个项目了，主力在ta另一个项目上，尝试自己编译，发现自己的AndroidStudio版本太低，各种报错就懒得弄了

- 插数据线，使用 `adb` 命令来获取权限访问 `/sdcard/Android/data/tv.danmaku.bili/download/` ，可以在电脑上用 `adb ls -l /xxx/xx` 和 `adb pull /xxx/xx` 来获取目录以及拉取文件到电脑，再在电脑上写脚本进行提取

- 安卓版的totalcommander（好像是论坛里找的新版），支持 `shizuku` ，可以将目录复制出来，然后用脚本处理

- 安卓版的termux应用里面有个 rish 支持 `shizuku` ，可以切换到 adb 权限，发现将termux下的golang编译的二进制文件放到 `TMPDIR=/data/local/tmp` 这个目录下，可以加上执行权限，我的另一个项目 `foxbook-golang` 里的程序可以执行，这样就可以在 adb 权限下启用一个http服务器，就可以通过http在termux普通用户中访问 `/sdcard/Android/data/tv.danmaku.bili/download/` ，这样就可以直接通过http地址，将音频视频流合并为视频 `ffmpeg -i http://127.0.0.1:2333/xxx/audio.m4s -i http://127.0.0.1:2333/xxx/video.m4s -c copy bili.mkv` 了，也可以通过http遍历该目录，获取json配置，弹幕xml，然后转换弹幕为ass字幕文件，即可将弹幕包含进视频了，这样基本就可以通过bash脚本来实现自己的目的，难点在于没有弹幕转字幕的现成工具，所幸找到了项目 <https://github.com/Hami-Lemon/converter> ，修改了一下，编译成termux和win下的版本

- TODO: 将目录复制出来后的处理脚本还没写，大概只要修改一下 `bilibili.cache.sh` 的读取逻辑即可，或者也可以写个golang程序一步到位，这个以后再说，写好了再更新到这里

# 文件说明:

- `bilibili.cache.sh` : 脚本: 根据adb权限下执行命令 `cd /sdcard/Android/data/tv.danmaku.bili/download/; find . -name entry.json > /sdcard/entrys.lst` 生成的entrys.lst 来一行行处理从http服务器下载m4s以合成mkv，通过控制 entrys.lst 的内容可以分批处理以节省空间

- `danmaku2ass_src.7z` : danmaku2ass 的源码

- `danmaku2ass_termux_android.7z` : danmaku2ass 可执行程序 termux 下的，其他的程序使用 `apt install ffmpeg curl wget` 来安装

- `danmaku2ass_win7p_x64.7z` : danmaku2ass 可执行程序 win 7+ x64 版

- `jj_termux_android.7z` : 解析json的命令行工具 termux 版

- `jj_win7p_x64.7z` : 解析json的命令行工具 win 7+ x64 版

# 依赖的项目

- [jj](https://github.com/tidwall/jj) : 用来解析json的命令行工具，感觉比jq好用，主页没提供termux版，所以放到项目中，注意下载后，加上可执行权限: `chmod a+x jj`

- danmaku2ass : 修改自 <https://github.com/Hami-Lemon/converter> : 功能是将弹幕文件 `danmaku.xml` 转换为 `danmaku.ass` 字幕文件，方便合成进mkv，原版的使用不太方便，需要用json配置来改变配置，且支持多个xml处理，修改成从标准输入读取xml内容，存为 `sub.ass` ，且可以通过开关 `-w 视频宽度` `-h 视频高度` `-s 字体大小` 来做设置，方便命令行调整，尤其是字体大小，项目中放有winx64，和android termux下的预编译版本，如果需要其他版本，可以自行编译或找我要

