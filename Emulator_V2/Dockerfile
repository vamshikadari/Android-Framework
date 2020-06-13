FROM ubuntu:xenial

LABEL maintainer vamshikadari454@gmail.com

ENV DEBIAN_FRONTEND=noninteractive

#Install necessary tools
RUN    apt-get -qqy update \
    && apt-get -qqy --no-install-recommends install openjdk-8-jdk ca-certificates tzdata zip unzip wget socat \
	   libqt5webkit5 qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils \
	   git xterm x11vnc xvfb openbox python-numpy python-xdg menu feh
	   
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre   	
ENV PATH="$PATH:$JAVA_HOME/bin"

ENV ANDROID_HOME="/android"

RUN mkdir $ANDROID_HOME

#Download Android SDK
RUN    wget -q https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip \
    && unzip *.zip -d $ANDROID_HOME \
    && rm *.zip 
 
ENV PATH=$PATH:$ANDROID_HOME/tools/bin 

RUN    mkdir -p ~/.android \
    && touch ~/.android/repositories.cfg

ARG ANDROID_API="android-29"
ENV ANDROID_VERSION $ANDROID_API

#Install necessary Android tools
RUN    yes | sdkmanager --sdk_root=$ANDROID_HOME "tools" \
    && yes | sdkmanager --update \
	&& yes | sdkmanager --licenses \
    && yes | sdkmanager "platform-tools" \
	&& yes | sdkmanager "platforms;$ANDROID_VERSION"
     
ENV PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator 

#Download noVNC and websockify
RUN    cd /root && git clone https://github.com/kanaka/noVNC.git \
    && cd noVNC/utils && git clone https://github.com/kanaka/websockify

#Remove runtime dependencies
RUN    apt-get remove -y zip unzip wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
	
ADD devices/ /$ANDROID_HOME/devices
ADD Android.png /$ANDROID_HOME
ADD rc.xml /$ANDROID_HOME
	
EXPOSE 5554 5555 6080

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 \
            CMD timeout 60 adb shell getprop dev.bootcomplete | grep "1"

ENTRYPOINT ["/entrypoint.sh"]