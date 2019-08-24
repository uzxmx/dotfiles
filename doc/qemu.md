# QEMU

Git revision: 1b46b4daa6fbf45eddcf77877379a0afac341df9

## Command line

```
-L path         set the directory for the BIOS, VGA BIOS and keymaps
-bios file      set the filename for the BIOS
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
