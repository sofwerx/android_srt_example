FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update

RUN apt-get install -y python3-pip python3 git build-essential sudo
RUN apt-get install -y autotools-dev automake autoconf libtool g++ autopoint make cmake bison flex yasm pkg-config gtk-doc-tools libxv-dev libx11-dev libpulse-dev python3-dev texinfo gettext build-essential pkg-config doxygen curl libxext-dev libxi-dev x11proto-record-dev libxrender-dev libgl1-mesa-dev libxfixes-dev libxdamage-dev libxcomposite-dev libasound2-dev libxml-simple-perl dpkg-dev debhelper build-essential devscripts fakeroot transfig gperf libdbus-glib-1-dev wget glib-networking libxtst-dev libxrandr-dev libglu1-mesa-dev libegl1-mesa-dev git subversion xutils-dev intltool ccache python3-setuptools
RUN apt-get install -y libpython-dev libpython2.7 libpython2.7-dev python-dev python2.7-dev libfuse2 libselinux1-dev libsepol1-dev fuse chrpath libfuse-dev

# Upstream trunk
RUN git clone https://gitlab.freedesktop.org/gstreamer/cerbero /cerbero
## Frozen known working build for android 0.15.0.1
#RUN git clone https://gitlab.freedesktop.org/ianblenke/cerbero /cerbero

WORKDIR /cerbero

RUN  git config --global user.email "ian@blenke.com"
RUN  git config --global user.name "Ian Blenke"

RUN sed -i -e 's%http://www.soft-switch.org/downloads/spandsp/%https://gstreamer.freedesktop.org/src/mirror/%' recipes/spandsp.recipe

RUN ls -la config/
RUN ls -la config/cross-android-universal.cbc

RUN ./cerbero-uninstalled -c config/cross-android-universal.cbc bootstrap
RUN ./cerbero-uninstalled -c config/cross-android-universal.cbc build bionic-fixup
RUN ./cerbero-uninstalled -c config/cross-android-universal.cbc build libiconv gnustl proxy-libintl
RUN ./cerbero-uninstalled -c config/cross-android-universal.cbc build srt
RUN ./cerbero-uninstalled -c config/cross-android-universal.cbc package gstreamer-1.0

RUN mkdir -p /gstreamer-android
RUN tar xjf /cerbero/gstreamer-1.0-android-universal-1.15.0.1-runtime.tar.bz2 -C /gstreamer-android/
RUN tar xjf /cerbero/gstreamer-1.0-android-universal-1.15.0.1.tar.bz2 -C /gstreamer-android
ENV GSTREAMER_ROOT_ANDROID=/gstreamer-android

RUN apt-get install -y unzip

RUN mkdir -p /android

WORKDIR /android

ENV ANDROID_SDK_VERSION=r25.2.3

RUN wget -q https://dl.google.com/android/repository/tools_${ANDROID_SDK_VERSION}-linux.zip \
 && unzip -q tools_${ANDROID_SDK_VERSION}-linux.zip \
 && rm tools_${ANDROID_SDK_VERSION}-linux.zip

ENV ANDROID_NDK_VERSION r18b

RUN wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip \
 && unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip \
 && rm android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip

ENV ANDROID_HOME=/android
ENV ANDROID_NDK_HOME=/android/android-ndk-${ANDROID_NDK_VERSION}
ENV PATH=${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${ANDROID_NDK_HOME}:$PATH

RUN mkdir -p ${ANDROID_HOME}/licenses \
 && touch ${ANDROID_HOME}/licenses/android-sdk-license \
 && echo "\n8933bad161af4178b1185d1a37fbf41ea5269c55" >> $ANDROID_HOME/licenses/android-sdk-license \
 && echo "\nd56f5187479451eabf01fb78af6dfcb131a6481e" >> $ANDROID_HOME/licenses/android-sdk-license \
 && echo "\ne6b7c2ab7fa2298c15165e9583d0acf0b04a2232" >> $ANDROID_HOME/licenses/android-sdk-license \
 && echo "\n84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license \
 && echo "\nd975f751698a77b662f1254ddbeed3901e976f5a" > $ANDROID_HOME/licenses/intel-android-extra-license

RUN apt-get update \
 && apt-get install -y software-properties-common

# Install Java.
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN yes | sdkmanager "platforms;android-23"
RUN mkdir -p ${ANDROID_HOME}/.android \
 && touch ~/.android/repositories.cfg ${ANDROID_HOME}/.android/repositories.cfg
RUN yes | sdkmanager "build-tools;25.0.2"

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

WORKDIR /android_srt_example
COPY . .

RUN mkdir -p /opt \
 && ln -s $ANDROID_HOME /opt/android-sdk-linux \
 && ln -s $ANDROID_NDK_HOME /opt/android-sdk-linux/ndk-bundle

RUN ./gradlew build

CMD sleep 3600
