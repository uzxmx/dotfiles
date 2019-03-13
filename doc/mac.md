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
