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

## How to just build Android system image

Remember to run `source build/envsetup.sh && lunch` to choose a target when in a new terminal.

If your changes effect other applications, use make systemimage, otherwise use make snod.

Notice: make systemimage will check dependency during compile progress, while make snod will not do this check, so the former command need more time than the latter.

## Run emulator

```
./prebuilts/android-emulator/linux-x86_64/emulator -kernel prebuilts/qemu-kernel/arm64/kernel-qemu -ramdisk out/target/product/generic/ramdisk.img -system out/target/product/generic/system.img -memory 2048  -no-window -verbose

# With userdata.img
./prebuilts/android-emulator/linux-x86_64/emulator -kernel prebuilts/qemu-kernel/arm64/kernel-qemu -ramdisk out/target/product/generic/ramdisk.img -system out/target/product/generic/system.img -sysdir out/target/product/generic -data out/target/product/generic/userdata.img -scale 0.7 -memory 2048  -partition-size 4096 -no-window -verbose

# May need to export ANDROID_PRODUCT_OUT
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

# This will rebuild all (cache will not be used)
./android/rebuild.sh

# This will use cache
cd objs
~/emu-master-dev/prebuilts/ninja/linux-x86/ninja
```
