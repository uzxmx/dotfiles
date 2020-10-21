# Mac

## How to input number with circle around?

Switch to Chinese input method, and press `Shift + Option + b`.

## Run qemu with customized kernel

qemu-system-x86_64 -kernel ~/shared/bzImage -initrd ~/shared/initramfs.cpio.gz -nographic -append "console=ttyS0"

## Sync a single project from aosp

./repo sync $PROJECT_NAME --no-tags --no-clone-bundle

## Run objective-c test in console

```
xcodebuild -scheme Development -workspace Foo.xcworkspace/ -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 8,OS=12.1' \
  -only-testing:FooTests/BarSpec test | xcpretty --test --color

xcodebuild -scheme Development -workspace Foo.xcworkspace/ -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 8,OS=12.1' \
  -only-testing:FooTests/BarSpec test | xcpretty -tc
```

## Mount NTFS with RW permissions

```
# Find device through spotlight profile
sudo ntfs-3g /dev/disk2s3 /mount_point
```

Refs: https://github.com/osxfuse/osxfuse/wiki/NTFS-3G

## `date` gives wrong time (several seconds late)

For 10.14 Mojave, execute `sudo sntp -sS pool.ntp.org`.

Ref: https://apple.stackexchange.com/a/117865

## Use external monitor when lid is closed

```
sudo pmset -b disablesleep 1
# Or
sudo pmset -a disablesleep 1

# Restore
sudo pmset -b disablesleep 0
# Or
sudo pmset -a disablesleep 0
```

Ref:

* https://apple.stackexchange.com/a/356255
* https://www.reddit.com/r/MacOS/comments/a4jmqd/keeping_macbook_awake_while_closing_the_lid/


## Open xcode project from terminal

```
xed -b <directory>
```

## How to make clang show header search paths

```
clang -E -x c++ - -v < /dev/null
```

## Pod commands

```
# Show pod spec
pod spec cat Masonry
pod spec cat Masonry --verbose

# Show available versions of a pod
pod trunk info Masonry
```

## How to use xcode beta version

By default xcode is installed at /Applications/Xcode.app/, after downloading a beta version,
you can put it into a different location in order not to affect the default version. In order
to activate it as the default developer directory, you can run:

```
xcode-select -s <path-to-your-new-xcode-version>/Contents/Developer
```

If you want to restore the active developer directory for the default xcode version, run:

```
xcode-select -s /Applications/Xcode.app/Contents/Developer
```

Run below if you want to show current active developer directory:

```
xcode-select -p
```

## Xcode build directory

The default build directory is `~/Library/Developer/Xcode/DerivedData`.

Ref: https://stackoverflow.com/a/5952841

## Use exception breakpoint

View -> Navigators -> Show Breakpoint Navigator

At the left-bottom of the panel, click `+` button, and select `Exception Breakpoint`.

## TODO why does an app built by two different versions of xcode behave differently in a same phone?

For example, an app built by xcode 10.2 works, but if built by xcode 11.2, it will throw
`Client error attempting to change layout margins of a private view`.

## How to make a bootable usb stick from an ISO file?

1. Convert .iso file to .img file:
   ```
   hdiutil convert -format UDRW -o /path/to/target.img /path/to/source.iso
   ```

   OS X tends to put the .dmg ending on the output file automatically. Rename the file by typing:

   ```
   mv /path/to/target.img.dmg /path/to/target.img
   ```

1. Run `diskutil list` to get the current list of devices

1. Insert your flash media

1. Run `diskutil list` again and determine the device node assigned to your flash media (e.g. /dev/disk2)

1. Run `diskutil unmountDisk /dev/diskN` (replace N with the disk number from the last command - in the previous example, N would be 2)

1. Execute `sudo dd if=/path/to/target.img of=/dev/rdiskN bs=1m`
   > Using /dev/rdisk instead of /dev/disk may be faster.

   > If you see the error dd: /dev/diskN: Resource busy, make sure the disk is not in use. Start the 'Disk Utility.app' and unmount (don't eject) the drive.

1. Run `diskutil eject /dev/diskN` and remove your flash media when the command completes
