# AOSP

## Download source

```
# Ref: https://mirrors.tuna.tsinghua.edu.cn/help/git-repo/
curl https://mirrors.tuna.tsinghua.edu.cn/git/git-repo -o repo
chmod a+x repo
export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo/'

mkdir WORKING_DIRECTORY
cd WORKING_DIRECTORY
repo init -u https://aosp.tuna.tsinghua.edu.cn/platform/manifest
repo sync
```

## Creating a case-sensitive disk image for OSX

```
hdiutil create -type SPARSE -fs 'Case-sensitive Journaled HFS+' -size 160g android.dmg

# If you need a larger volume later, you can resize the sparse image with the following command
hdiutil resize -size <new-size-you-want>g android.dmg.sparseimage

# Mount the android file image
hdiutil attach android.dmg.sparseimage -mountpoint mountpoint

# Unmount the android file image
hdiutil detach mountpoint
```

## How to just build Android system image

Remember to run `source build/envsetup.sh && lunch` to choose a target when in a new terminal.

If your changes effect other applications, use make systemimage, otherwise use make snod.

Notice: make systemimage will check dependency during compile progress, while make snod will not do this check, so the former command need more time than the latter.

## How to create ramdisk.img

```
cd path-to-ramdisk
find . | cpio -o -Hnewc | gzip -9 > ../ramdisk.img
```

## Run emulator

```
./prebuilts/android-emulator/linux-x86_64/emulator -kernel prebuilts/qemu-kernel/arm64/kernel-qemu -ramdisk out/target/product/generic/ramdisk.img -system out/target/product/generic/system.img -memory 2048  -no-window -verbose

# With userdata.img
./prebuilts/android-emulator/linux-x86_64/emulator -kernel prebuilts/qemu-kernel/arm64/kernel-qemu -ramdisk out/target/product/generic/ramdisk.img -system out/target/product/generic/system.img -sysdir out/target/product/generic -data out/target/product/generic/userdata.img -scale 0.7 -memory 2048  -partition-size 4096 -no-window -verbose

# May need to export ANDROID_BUILD_TOP and ANDROID_PRODUCT_OUT.
# ANDROID_BUILD_TOP should point to root directory of the source tree.
# ANDROID_PRODUCT_OUT should point to the directory that contains generated images.
export ANDROID_BUILD_TOP=~/aosp
export ANDROID_PRODUCT_OUT=~/aosp/out/target/product/generic_x86_64

# Run for x86_64 arch
./prebuilts/android-emulator/linux-x86_64/emulator -kernel prebuilts/qemu-kernel/x86_64/kernel-qemu -ramdisk out/target/product/generic_x86_64/ramdisk.img -system out/target/product/generic_x86_64/system.img -sysdir out/target/product/generic_x86_64 -data out/target/product/generic_x86_64/userdata.img -scale 0.7 -memory 2048  -partition-size 4096 -no-window -verbose

# With kernel-ranchu, and without CPU accelerator
./prebuilts/android-emulator/linux-x86_64/emulator -kernel out/target/product/generic_x86_64/kernel-ranchu -ramdisk out/target/product/generic_x86_64/ramdisk.img -system out/target/product/generic_x86_64/system.img -sysdir out/target/product/generic_x86_64 -data out/target/product/generic_x86_64/userdata.img -memory 2048 -no-window -verbose -no-accel

# With customized qemu emulator, customized kernel, show kernel message, 1 CPU core, and redirect output to debug.log file
./android-qemu/objs/emulator -kernel ~/android-kernel/goldfish/arch/x86_64/boot/bzImage -ramdisk ~/aosp/out/target/product/generic_x86_64/ramdisk.img -system ~/aosp/out/target/product/generic_x86_64/system.img -sysdir ~/aosp/out/target/product/generic_x86_64 -data ~/aosp/out/target/product/generic_x86_64/userdata.img -memory 2048 -no-window -verbose -no-accel -show-kernel -ranchu -cores 1 >debug.log

# We can also feed emulator with `-debug all`, that will enable emulator debug log.
```

## Update working tree

```
# Fetch updates from remote
repo sync

# Only update working tree, don't fetch
repo sync -l
```

## Download and build kernel source

```
git clone https://aosp.tuna.tsinghua.edu.cn/kernel/goldfish
cd goldfish
git checkout -b android-4.14 remotes/origin/android-4.14
make x86_64_ranchu_defconfig
make -j4
```

## Download and build emulator

```
mkdir emu-master-dev
cd emu-master-dev
repo init -u https://aosp.tuna.tsinghua.edu.cn/platform/manifest -b emu-master-dev
repo sync

cd android
source envsetup.sh

# This will rebuild all, and cache will not be used. (We must execute this for initial setup)
./rebuild.sh

# After initial setup, and ./objs/build.ninja exists, we can do this
cd objs && ninja
```

## Trouble shooting

### When running emulator on OSX, it throws: 'dyld: Library not loaded: @rpath/libQt5CoreAndroidEmu.5.12.1.dylib'

```
# Suppose current working directory is the qemu root directory.
export DYLD_LIBRARY_PATH=$(pwd)/android/objs/lib64/qt/lib:$(pwd)/android/objs/lib64
```

## Too many open files

You need to increase open file descriptors limit by `ulimit -S -n 2048`. The change is only for current shell.
You may want to add it to shell startup file to make the change permanently.

On OSX, we can also use `launchctl limit` to change the limit. Using `launchctl limit` will make the change permanently.
If you're using iTerm, be sure to restart it after you make that change.

```
# Display all kinds of limits
sudo launchctl limit

# Set soft limit to 2048, and hard limit to unlimited
sudo launchctl limit maxfiles 2048 unlimited

# Set both soft and hard limit to 2048
sudo launchctl limit maxfiles 2048
```
