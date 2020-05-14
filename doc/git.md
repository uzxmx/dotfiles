## Push all branches of a remote to a new remote from local

```
git push origin 'refs/remotes/old-origin/*:refs/heads/*'
```

## Git error: Host Key Verification Failed

```
# Removes all keys belonging to hostname from a known_hosts file
ssh-keygen -R example.com

# Gather SSH public keys
ssh-keyscan -t rsa example.com >> ~/.ssh/known_hosts
```

## Run git with specified ssh private key

```
# This requires Git 2.10+
GIT_SSH_COMMAND='ssh -i /path/to/id_rsa -o IdentitiesOnly=yes -F /dev/null' git clone git@example.com:foo.git
```

## Change git ssh protocol to https protocol for github

```
git config --global url.https://github.com/.insteadOf git@github.com:
```

## Generate and apply patch

```
# Generate patch
git diff --binary >foo.patch
git diff --cached --binary >foo.patch

# Apply patch
git apply foo.patch
```

## Diff two directories with color

```
git diff --no-index dir1 dir2
```

## Find which branches a commit is on

```
git branch --contains <commit>
git branch -r --contains <commit>
```

## Delete tag

```
# Delete remote tag
git push --delete origin tagname

# Delete local tag
git tag -d tagname
```

## Pull git submodules after cloning

```
git submodule update --init
```

Ref: https://stackoverflow.com/questions/16773642/pull-git-submodules-after-cloning-project-from-github
