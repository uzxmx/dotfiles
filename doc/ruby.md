## Run specified tests for minitest

```
rake test TEST=test/test_foo.rb TESTOPTS="--name=test_foo_method -v"
ruby -Ilib -Itest test/test_foo.rb --name=test_foo_method
```

Ref: https://guides.rubyonrails.org/testing.html#the-rails-test-runner

## RSpec

Configuration options are loaded from `~/.rspec`, `.rspec`, `.rspec-local`,
command line switches, and the `SPEC_OPTS` environment variable (listed in
lowest to highest precedence; for example, an option in `~/.rspec` can be
overridden by an option in `.rspec-local`).

```
SPEC_OPTS='--fail-fast' bundle exec rspec
SPEC_OPTS='--no-fail-fast' bundle exec rspec
```

Ref: https://relishapp.com/rspec/rspec-core/v/3-7/docs/configuration/read-command-line-configuration-options-from-files

## Pass in compiler options when installing a gem

For example, on Mac 10.15.6, installing puma 4.3.5 fails with:

```
puma_http11.c:203:22: error: implicitly declaring library function 'isspace' with type 'int (int)' [-Werror,-Wimplicit-function-declaration]
```

We can resolve this issue by:

```
gem install puma:4.3.5 -- --with-cflags="-Wno-error=implicit-function-declaration"
```

Ref: https://github.com/puma/puma/issues/2304
