## Install arm toolchains on ubuntu

```
sudo apt-get install gcc-arm-linux-gnueabi

# The below may also work.
# sudo apt-get install gcc-arm-none-eabi
```

## Run arm program on x86 host

```
sudo apt-get install qemu
arm-linux-gnueabi-gcc -o main main.c
qemu-arm -L /usr/arm-linux-gnueabi main
```

## Build arm linux kernel

```
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.14.7.tar.xz
tar xvJf linux-4.14.7.tar.xz
cd linux-4.14.7
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm vexpress_defconfig
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm
qemu-system-arm -M vexpress-a9 -m 512M -kernel linux-4.14.7/arch/arm/boot/zImage -dtb linux-4.14.7/arch/arm/boot/dts/vexpress-v2p-ca9.dtb -nographic -append "console=ttyAMA0"
```

## Quit from qemu

```
Press CTRL-A, and then press X
```

## Build rootfs

```
wget https://busybox.net/downloads/busybox-1.27.2.tar.bz2
tar xjvf busybox-1.27.2.tar.bz2
cd busybox-1.27.2
make defconfig
make CROSS_COMPILE=arm-linux-gnueabi-
make install CROSS_COMPILE=arm-linux-gnueabi-

cd ..
mkdir rootfs
cp -r busybox-1.27.2/_install/* rootfs/
mkdir rootfs/lib
cp -P /usr/arm-linux-gnueabi/lib/* rootfs/lib

# Make 4 tty devices
mkdir -p rootfs/dev
sudo mknod rootfs/dev/tty1 c 4 1
sudo mknod rootfs/dev/tty2 c 4 2
sudo mknod rootfs/dev/tty3 c 4 3
sudo mknod rootfs/dev/tty4 c 4 4

dd if=/dev/zero of=a9rootfs.ext3 bs=1M count=32
mkfs.ext3 a9rootfs.ext3
mkdir tmpfs
sudo mount -t ext3 a9rootfs.ext3 tmpfs/ -o loop
sudo cp -r rootfs/* tmpfs/
sudo umount tmpfs

# run with rootfs
qemu-system-arm -M vexpress-a9 -m 512M -kernel linux-4.14.7/arch/arm/boot/zImage -dtb linux-4.14.7/arch/arm/boot/dts/vexpress-v2p-ca9.dtb -nographic -append "root=/dev/mmcblk0 console=ttyAMA0 rw init=/linuxrc" -sd a9rootfs.ext3
```
