cp -R ~/ijk-cmd/android ~/ijkplayer/android
cp -R ~/ijk-cmd/config ~/ijkplayer/config
cp -R ~/ijk-cmd/ijkmedia ~/ijkplayer/ijkmedia

cd ~/ijkplayer/android/contrib/ffmpeg-arm64/fftools
rm -f ffmpeg.c
ln -s ../../ffmpeg.c ffmpeg.c
rm -f cmdutils.c
ln -s ../../cmdutils.c cmdutils.c

cd ~/ijkplayer/android/contrib/ffmpeg-armv5/fftools
rm -f ffmpeg.c
ln -s ../../ffmpeg.c ffmpeg.c
rm -f cmdutils.c
ln -s ../../cmdutils.c cmdutils.c

cd ~/ijkplayer/android/contrib/ffmpeg-armv7a/fftools
rm -f ffmpeg.c
ln -s ../../ffmpeg.c ffmpeg.c
rm -f cmdutils.c
ln -s ../../cmdutils.c cmdutils.c

cd ~/ijkplayer/android/contrib/ffmpeg-x86/fftools
rm -f ffmpeg.c
ln -s ../../ffmpeg.c ffmpeg.c
rm -f cmdutils.c
ln -s ../../cmdutils.c cmdutils.c

cd ~/ijkplayer/android/contrib/ffmpeg-x86_64/fftools
rm -f ffmpeg.c
ln -s ../../ffmpeg.c ffmpeg.c
rm -f cmdutils.c
ln -s ../../cmdutils.c cmdutils.c

cd ~/ijkplayer/config
rm -f module.sh
ln -s module-ffmpeg.sh module.sh

