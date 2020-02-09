## Commands

```
# Exclude ./kubespray directory, note the differences with --exclude='kubespray' and --exclude='kubespray/'
rsync -avuz -e 'ssh -p 2222 -o "SetEnv=AssetName=prod1 Interactive=no"' --exclude='/kubespray/' . user@host:/tmp/foo

rsync -avuz -e 'ssh -p 2222 -o "SetEnv=AssetName=prod1 Interactive=no"' --exclude='/.git/' --exclude='/kubespray/' --exclude='/locals/' --exclude='*.swp' --exclude='*.swo' . user@host:/tmp/foo
```
