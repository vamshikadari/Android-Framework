#!/bin/bash

if [[ $DEVICE == "" ]]; then

    DEVICE="Nexus One"
	
fi

var=$DEVICE
PROFILE_NAME=$( echo "${var// /_}" | awk '{print tolower($0)}' )
SKIN_NAME=$PROFILE_NAME

if [[ $PROFILE_NAME == *"samsung"* ]]; then

    cp /android/devices/profiles/$PROFILE_NAME.xml ~/.android/$PROFILE_NAME.xml
	mv ~/.android/$PROFILE_NAME.xml ~/.android/devices.xml
	 
fi

if [[ $SYSIMAGE == "" ]]; then
	
	SYSIMAGE="google_apis;x86"
	
fi

echo "creating Emulator $DEVICE with $ANDROID_VERSION,$SYSIMAGE"
yes | sdkmanager "system-images;$ANDROID_VERSION;$SYSIMAGE"
echo "no" | avdmanager create avd -n emuTest -k "system-images;$ANDROID_VERSION;$SYSIMAGE" --device "$DEVICE"
echo -e "\nemulator created"

#increasing ramSize for emulator to deal with system is n't responding issue
echo "hw.ramSize=1024" >> /root/.android/avd/emuTest.avd/config.ini
echo "disk.dataPartition.size=2G" >> /root/.android/avd/emuTest.avd/config.ini
echo "vm.heapSize=512" >> /root/.android/avd/emuTest.avd/config.ini

if [[ $PROFILE_NAME == "pixel" || $PROFILE_NAME == "pixel_xl" ]];then

    SKIN_NAME=${PROFILE_NAME}_silver

fi

#adding skin path to created avd
if [[ -d /android/devices/skins/$SKIN_NAME ]]; then

    echo "skin.path=/android/devices/skins/$SKIN_NAME" >> ~/.android/avd/emuTest.avd/config.ini
	
fi

avdmanager list avd

#port forwarding
for ip in $( hostname -I ); do
	socat tcp-listen:5554,bind=$ip,fork tcp:127.0.0.1:5554 &
	socat tcp-listen:5555,bind=$ip,fork tcp:127.0.0.1:5555 &
done 

#set background wallpaper
mkdir -p ~/wallpaper
cp /$ANDROID_HOME/Android.png ~/wallpaper/Android.png

#set openbox settings
cp /$ANDROID_HOME/rc.xml /etc/xdg/openbox/rc.xml

#Disable sandbox
export QTWEBENGINE_DISABLE_SANDBOX=1

#Xvfb, x11vnc setup
export DISPLAY=:0
Xvfb :0 -screen 0 1280x720x24+32 > /dev/null 2>&1 &
sleep 5
feh --bg-max ~/wallpaper/Android.png &
openbox-session &
x11vnc -display :0 -nopw -listen localhost -xkb -ncache 10 -ncache_cr -forever > /dev/null 2>&1 &
cd /root/noVNC && ln -s vnc.html index.html && ./utils/launch.sh --vnc localhost:5900 --listen 6080 > /dev/null 2>&1 &

#Start emulator
emulator -avd emuTest -use-system-libs -noaudio -gpu swiftshader_indirect