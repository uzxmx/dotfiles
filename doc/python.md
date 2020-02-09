## How can we list package versions when using `pip`

```
# Install yolk3k
sudo pip install yolk3k

# Then list package versions
yolk -V <package>
```

## How can we install a specific version of a package when using `pip`

```
pip install <package>==<specific version>
```

## Ruby struct-like class in Python

```
from collections import namedtuple
Person = namedtuple('Person', ('forename', 'surname'))
person1 = Person('John', 'Doe')
person2 = Person(forename='Adam', surname='Monroe')
person1.forename # 'John'
person2.surname # 'Monroe'
```

## Default timeout for requests library

For python 3.x

```
import requests
from requests.adapters import TimeoutSauce

REQUESTS_TIMEOUT_SECONDS = 2

class CustomTimeout(TimeoutSauce):
    def __init__(self, *args, **kwargs):
        if kwargs["connect"] is None:
            kwargs["connect"] = REQUESTS_TIMEOUT_SECONDS
        if kwargs["read"] is None:
            kwargs["read"] = REQUESTS_TIMEOUT_SECONDS
        super().__init__(*args, **kwargs)

# Set it globally, instead of specifying ``timeout=..`` kwarg on each call.
requests.adapters.TimeoutSauce = CustomTimeout

resp = requests.get('http://httpbin.org/delay/5')
print(resp)
```

## Tips on debug

### Get libraries paths

```
import sys
sys.path
```

### Get module path

```
# Method 1
import os
import somemodule
print(somemodule.__file__)
print(os.path.abspath(somemodule.__file__))

# Method 2
import os
import somemodule
import inspect
inspect.getfile(os)
inspect.getfile(somemodule)
```

## Regexp for Python 2

```
Text:
PASS_MIN_DAYS     0

Regexp pattern with named group:
^PASS_MIN_DAYS(?P<whitespace>\s+)

Replacement:
PASS_MIN_DAYS\g<whitespace>0

Regexp pattern without named group:
^PASS_MIN_DAYS(\s+)

Replacement:
PASS_MIN_DAYS\g<1>0
```

Ref: https://docs.python.org/2/library/re.html
