automount cookbook
------------------
This cookbook provides libraries, resources and providers to configure and manage automount points.

Tested on

* Ubuntu 12.04



Requirements
------------
This cookbook is pretty much standalone.

Usage
-----
Include the `default` recipe and specify `automount` resources.


Attributes
----------

- `['automount']['timeout']` - Idle timeout in seconds.  default 600


Recipes
-------

### default
Sets up autofs.

Resources/Providers
-------------------

### automount
Similar to Chef `mount` resource.

```ruby
automount "/mnt/testshare1" do
  fstype   "cifs"
  device   "//127.0.0.1/TestShare"
  options  "noperm,noexec,username=testshare,password=secretpass"
  action :enable
end
```

License & Authors
-----------------
- Author:: Ted Chen (<ted@nephilagraphic.com>)

```text
Copyright 2014, Nephila Graphic

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
