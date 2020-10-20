# QEMU

Git revision: 1b46b4daa6fbf45eddcf77877379a0afac341df9

## Command line

```
-L path         set the directory for the BIOS, VGA BIOS and keymaps
-bios file      set the filename for the BIOS
```

```
# Run with custom system root.
qemu-arm -L /opt/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi/arm-linux-gnueabi/libc a.out
```

## QEMU for arm

### Key points

```
arm_cpu_realizefn
qemu_init_vcpu

# target/arm/translate.c
arm_tr_translate_insn
disas_arm_insn
```

## QEMU for x86_64

On booting, `pc-bios/bios-256k.bin` is used. The BIOS is SeaBIOS (https://www.seabios.org/SeaBIOS).

## Debug boot process for x86

```
qemu-system-i386 -kernel arch/x86/bzImage -m 512 -nographic -s -S

gdb -ex 'file out/rom.o' -ex 'target remote :1234' -ex 'b startBoot' -ex 'c'
gdb -ex 'target remote :1234' -ex 'b *0xf185f' -ex 'c'
```

Ref: https://github.com/cloudius-systems/osv/wiki/OSv-early-boot-(MBR)

## SeaBIOS

Interrupt service routine is setup in SeaBIOS (src/post.c ivt_init)

## Trouble shooting

### When running qemu-arm in user mode, the following error happens.

```
Unable to reserve 0xffff0000 bytes of virtual address space at 0x1000 (Success)
for use as guest address space (check yourvirtual memory ulimit setting,
min_mmap_addr or reserve less using -R option), 0x10000
```

The error happens because the mmaped address is not matched with the expected
address.

```
--- a/linux-user/elfload.c
+++ b/linux-user/elfload.c
@@ -2331,7 +2331,7 @@ static void pgb_reserved_va(const char *image_name, abi_ulong guest_loaddr,
     assert(guest_base != 0);
     test = g2h(0);
     addr = mmap(test, reserved_va, PROT_NONE, flags, -1, 0);
-    if (addr == MAP_FAILED || addr != test) {
+    if (addr == MAP_FAILED) {
         error_report("Unable to reserve 0x%lx bytes of virtual address "
                      "space at %p (%s) for use as guest address space (check your"
                      "virtual memory ulimit setting, min_mmap_addr or reserve less "
```
