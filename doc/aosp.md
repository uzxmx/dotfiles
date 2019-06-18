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

If your changes effect other applications, use make systemimage, otherwise use make snod.

Notice:make systemimage will check dependency during compile progress, while make snod will not do this check, so the former command need more time than the latter.

## Run emulator

```
./prebuilts/android-emulator/linux-x86_64/emulator -kernel prebuilts/qemu-kernel/arm64/kernel-qemu -ramdisk out/target/product/generic/ramdisk.img -system out/target/product/generic/system.img -memory 2048  -no-window -verbose
./prebuilts/android-emulator/linux-x86_64/emulator -kernel prebuilts/qemu-kernel/arm64/kernel-qemu -ramdisk out/target/product/generic/ramdisk.img -system out/target/product/generic/system.img -sysdir out/target/product/generic -data out/target/product/generic/userdata.img -scale 0.7 -memory 2048  -partition-size 4096 -no-window -verbose
```
