# Travis

## Installation

```
gem install travis
```

## Login

Create a token for travis from github, then execute:

```
travis login --github-token YOUR_GITHUB_TOKEN
```

## Encrypt value

```
# Create secure api_key for github releases
travis encrypt "$TRAVIS_GITHUB_TOKEN" --add deploy.api_key
```

Ref:

* https://docs.travis-ci.com/user/environment-variables/#defining-encrypted-variables-in-travisyml
* https://docs.travis-ci.com/user/encryption-keys/
