# Android GStreamer sample player application

Download and extract the universal GStreamer Android binaries to
a directory of your choice.

<https://gstreamer.freedesktop.org/data/pkg/android/>

Edit gradle.properties in order to set gstAndroidRoot to point to the
unpacked GStreamer Android binaries.

## Building gstreamer for android with SRT

Presently, you must use cerbero to build srt for android universal, and then the gstreamer-1.0 package.

	export GSTREAMER_ROOT_ANDROID=/opt/gstreamer-android/current
	mkdir -p $GSTREAMER_ROOT_ANDROID
	git clone https://gitlab.freedesktop.org/gstreamer/cerbero
	cd cerbero
	./cerbero-uninstalled -c config/cross-android-universal.cbc bootstrap
	./cerbero-uninstalled -c config/cross-android-universal.cbc build srt
	./cerbero-uninstalled -c config/cross-android-universal.cbc package gstreamer-1.0
        tar xjf gstreamer-1.0-android-universal-1.15.0.1-runtime.tar.bz2 -C $GSTREAMER_ROOT_ANDROID
	tar xjf gstreamer-1.0-android-universal-1.15.0.1.tar.bz2 -C $GSTREAMER_ROOT_ANDROID

## Build and deploy on the command line

To build and deploy the srt example to your device, use a command similar to:

```bash
$ PATH=~/dev/android/tools/bin:~/dev/android/ndk-bundle:$PATH ANDROID_HOME="$HOME/dev/android/" ./gradlew installDebug
```

## Run the application on the device

```bash
$ adb shell am start -n org.freedesktop.gstreamer.srt_example/.SRTExample
```

To see the GStreamer logs at runtime:

```bash
$ adb logcat | egrep '(gst)'
```

## Build and run from Android Studio

Launch Android-studio, opening this folder as a project.

The project should build automatically, once it has done successfully,
it should be possible to run the project with Run > Run 'app', provided
a device is attached and USB debugging enabled.

The logs can be seen in the logcat tab.
