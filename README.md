## **ijkplayer 编译支持 ffmpeg 命令行**

在 windows 10 的 linux 子系统 （ubuntu18.04）下完成。与linux无异。

##### 1、安装 Git，jdk

```
sudo apt-get install git
sudo apt-get install openjdk-8-jdk
```

##### 2、下载 ndk 10re(高版本编译会报错)，sdk

ndk: https://developer.android.google.cn/ndk/downloads/older_releases#ndk-10c-downloads

sdk: http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz

ndk 解压到 /usr/local/android-ndk-r10e

sdk 解压到 /usr/local/android-sdk-linux

在windows下载拷贝过来的需要设置权限

```
sudo unzip android-ndk-r10e-linux-x86_64.zip /usr/local
sudo tar -xvzf android-sdk_r24.4.1-linux.tgz /usr/local
cd /usr/local/android-ndk-r10e
sudo chmod -R +755 .
cd /usr/local/android-sdk-linux
sudo chmod -R +755 .
```

更新下载sdk包

```
cd /usr/local/android-sdk-linux/tools
./android update sdk --no-ui
```

##### 3、修改环境变量

sudo vi /etc/profile

插入（根据实际路径修改）

```
JAVA_HOME=/usr/local/java
CLASSPATH=$JAVA_HOME/lib/
PATH=$PATH:$JAVA_HOME/bin
export PATH JAVA_HOME CLASSPATH
export ANDROID_HOME=/usr/local/android-sdk-linux
export PATH=$ANDROID_HOME/tools:$PATH
export ANDROID_NDK=/usr/local/android-ndk
export PATH=$PATH:$ANDROID_NDK
```


如果是wsl，path变量会包含windows的路径，可能会出错，可以直接将path修改为

```
export PATH=/usr/local/android-sdk-linux/tools:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/usr/local/java/bin:/usr/local/android-ndk
```

使环境变量生效

```
source /etc/profile
```

##### 4、下载ijkplayer和ffmpeg源码

```text
git clone https://github.com/Bilibili/ijkplayer.git ijkplayer
cd ijkplayer
git checkout -B latest k0.8.8
./init-android.sh
如果需要openssl
./init-android-openssl.sh
```

以上操作网上可参考的例子

##### 5、下载很漫长，下载完成后，下载命令行修改

```
cd
git clone https://github.com/qinyoyo/ijk-cmd ijk-cmd
chmod +755 ~/ijk-cmd/initcmd.sh
~/ijk-cmd/initcmd.sh
```

##### 6、编译

```
cd ~/ijkplayer/android/contrib

需要openssl的话
./compile-openssl.sh clean
./compile-openssl.sh all

./compile-ffmpeg.sh clean
./compile-ffmpeg.sh all

cd ..
./compile-ijk.sh all
```

##### 7、在android studio中使用

1）在各个架构下可以得到生成的 so文件,如：

~/ijkplayer/android/ijkplayer/ijkplayer-arm64/src/main/libs/arm64-v8a

2）java源码

~/ijkplayer/android/ijkplayer/ijkplayer-java/src/main目录下的java目录拷贝到android应用的 src/main下

##### 8、调用方法

```
String dir = this.getCacheDir().getAbsolutePath(); 
new IjkMediaPlayer().ffmpegExec(new String[] {
    dir+"/ffmpeg",
    "-i", audioFilePath,
    "-af", "silencedetect=noise=0.1:duration=0.5",
    "-f", "null", "-",
    ">"+dir+"/silencedetect.log"
});
```

1）第一个参数可以设置决定目录，以保证ffmpeg操作文件可写。如-report会在该目录下写文件，如果不带目录，report写文件会报错。因此一般使用  dir+"/ffmpeg"

2）输出重定向到文件，通过增加最后一个参数实现

		>: 输出到 dir+"/ffmpeg"(第一个参数指定),覆盖
		>>: 附加到 dir+"/ffmpeg"(第一个参数指定)
		>文件名: 输出到指定文件
		>>文件名:附加到指定文件



**备注：**

1、windows 下访问 wsl子系统文件， 文件浏览器 输入 \\\\wsl$

2、wsl访问windows目录  /mnt/c/,/mnt/d/ ...