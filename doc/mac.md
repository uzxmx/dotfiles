# Mac

## How to input number with circle around?

Switch to Chinese input method, and press `Shift + Option + b`.

## Run qemu with customized kernel

qemu-system-x86_64 -kernel ~/shared/bzImage -initrd ~/shared/initramfs.cpio.gz -nographic -append "console=ttyS0"

## Sync a single project from aosp

./repo sync $PROJECT_NAME --no-tags --no-clone-bundle

## Run objective-c test in console

xcodebuild -scheme Development -workspace CareVoice.xcworkspace/ -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 8,OS=12.1' -only-testing:CareVoiceTests/KYClaimCellSpec test | xcpretty --test --color
xcodebuild -scheme Development -workspace CareVoice.xcworkspace/ -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 8,OS=12.1' -only-testing:CareVoiceTests/KYStepManagerSpec test | xcpretty -tc

## Mount NTFS with RW permissions

```
# Find device through spotlight profile
sudo ntfs-3g /dev/disk2s3 /mount_point
```

Refs: https://github.com/osxfuse/osxfuse/wiki/NTFS-3G

## `date` gives wrong time (several seconds late)

For 10.14 Mojave, execute `sudo sntp -sS pool.ntp.org`.

Ref: https://apple.stackexchange.com/a/117865
