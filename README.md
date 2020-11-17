## **ijkplayer 编译支持 ffmpeg 命令行**

重新编译 ijkplayer， 支持 ffmpeg 的命令行运行模式 （command line）。

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

##### 9、修改记录

###### 1）ffmpeg.c

​		增加重定向输出支持

```
// add by qinyoyo, for redirect

static FILE * av_log_file_handler = 0;
static void log_file_output(void* ptr, int level, const char* fmt, va_list vl) {   
    if (av_log_file_handler) {
        vfprintf(av_log_file_handler, fmt, vl);
    }
}
static void set_av_log_callback(FILE* file) {
    if (file) {
        av_log_file_handler = file;
        av_log_set_callback(log_file_output);
    }
    else {
        if (av_log_file_handler) fclose(av_log_file_handler);
        av_log_file_handler = 0;
        av_log_set_callback(0);
    }
}
//
```

增加当前目录设置

        int64_t ti;
    // add by qinyoyo for file write
    	char buf[512];
    	strcpy(buf,argv[0]);
    	int p=strlen(buf)-1;
    	while (p && buf[p]!='/' ) p--;
    	if (p>=0) buf[p]=0;
    	av_log(NULL, AV_LOG_ERROR, "chdir to \"%s\"\n", buf);
    	chdir(buf);  
    
    // add by qinyoyo, for redirect
        FILE * logFile = 0;
        if (argc > 1 && argv[argc-1][0] == '>') {  // redirect
            int append = 0;
            char* fileName = 0;
            int len = strlen(argv[argc - 1]);
            if (len == 1) {
                append = 0;
                fileName = argv[0];
            }
            else if (len == 2 && argv[argc - 1][1] == '>') {
                append = 1;
                fileName = argv[0];
            }
            else if (argv[argc - 1][1] == '>') {
                append = 1;
                fileName = argv[argc - 1]+2;
            }
            else {
                append = 0;
                fileName = argv[argc - 1] + 1;
            }
            if (fileName && *fileName) {
                logFile = fopen(fileName, append ? "a+" : "wt");
                if (logFile) set_av_log_callback(logFile);
            }
            argc--;
        }
    //
退出初始化

```
if ((decode_error_stat[0] + decode_error_stat[1]) * max_error_rate < 			    decode_error_stat[1])
        exit_program(69);

// add by qinyoyo for ffmpeg command line
    nb_filtergraphs = 0;
    nb_output_files = 0;
    nb_output_streams = 0;
    nb_input_files = 0;
    nb_input_streams = 0;
    if (logFile) set_av_log_callback(0);
// 
```

###### 2）cmdutils.c

删除退出程序函数代码

```
void exit_program(int ret)
{
	/* delete by qinyoyo for ffmpeg command line
    if (program_exit)
        program_exit(ret);
    exit(ret);
    */
}
```

###### 3）ijkplayer_jin.c

增加jni函数

```
// add FFmpegApi_exec by qinyoyo for ffmpeg command line
int main(int argc, char ** argv);
static jint IjkMediaPlayer_exec(JNIEnv *env,jobject weak_this,jobjectArray cmd){
    int len = (*env)->GetArrayLength(env,cmd);
    char *argv[len];
    int i;
    for(i = 0;i < len;++i){
        argv[i] = (char *) (*env)->GetStringUTFChars(env,(jstring) (*env)->GetObjectArrayElement(env,cmd,i),0);
    }
    return main(len,argv);
}
```

jni函数动态注册列表

    { "_setFrameAtTime",        "(Ljava/lang/String;JJII)V", (void *) IjkMediaPlayer_setFrameAtTime },
    { "ffmpegExec",             "([Ljava/lang/String;)I",   (void *) IjkMediaPlayer_exec},  // add FFmpegApi_exec by qinyoyo for ffmpeg command line
###### 4）do-compile-ffmpeg.sh

增加编译连接fftools的控制

```
#---  add by qinyoyo for ffmpeg command line ---
export CONFIG_FFMPEG=yes
#-----------------------------------------------

#--- add fftools to FF_MODULE_DIRS by qinyoyo for ffmpeg command line
FF_MODULE_DIRS="compat libavcodec libavfilter libavformat libavutil libswresample libswscale fftools"
```

###### 5）IjkMediaPlayer.java

增加native调用函数,使用成员函数而非静态函数，确保jni初始化后才可调用

```
    public native int  ffmpegExec(String command[]);  // add by qinyoyo for ffmpeg command line
```

###### 6）module-ffmpeg.sh

根据需要修改 module-default.sh必须的参数

```
export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-ffmpeg"
```



**备注：**

1、windows 下访问 wsl子系统文件， 文件浏览器 输入 \\\\wsl$

2、wsl访问windows目录  /mnt/c/,/mnt/d/ ...