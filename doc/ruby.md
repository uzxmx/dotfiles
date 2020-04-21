## Run specified tests for minitest

```
rake test TEST=test/test_foo.rb TESTOPTS="--name=test_foo_method -v"
ruby -Ilib -Itest test/test_foo.rb --name=test_foo_method
```

Ref: https://guides.rubyonrails.org/testing.html#the-rails-test-runner
