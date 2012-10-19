# Riak Ruby Migration

This script uses the `riak-client` to perform some basic maintenance 
operations on one or two clusters.  This is not intended to be used 
in production, and this is not optimized for performance.

## Installation

This script requires Ruby.  Please install Ruby according to your 
operating system.

Development dependencies are handled with bundler. Install bundler
(`gem install bundler`) and run this command in each sub-project to
get started:

``` bash
$ bundle install
```

Edit the file config.yml to match your clusters, which should be 
called 'A' and 'B' if you have a second one.

## Examples

Transfer everything in Cluster A to Cluster B:
``` bash
$ bundle exec rake riak:transfer:A_to_B
```

Log every key to ./log/keys_X.csv where X is the cluster:
``` bash
$ bundle exec rake riak:log_keys:A
```

Log every key and BASE64-encoded each value to ./log/data_X.csv where X is the cluster:
``` bash
$ bundle exec rake riak:log_data:A
```

## How to Contribute

* Fork the project on [Github](http://github.com/basho/riak-ruby-client).  If you have already forked, use `git pull --rebase` to reapply your changes on top of the mainline. Example:

    ``` bash
    $ git checkout master
    $ git pull --rebase basho master
    ```
* Create a topic branch. If you've already created a topic branch, rebase it on top of changes from the mainline "master" branch. Examples:
  * New branch:

        ``` bash
        $ git checkout -b topic
        ```
  * Existing branch:

        ``` bash
        $ git rebase master
        ```
* Write an RSpec example or set of examples that demonstrate the necessity and validity of your changes. **Patches without specs will most often be ignored. Just do it, you'll thank me later.** Documentation patches need no specs, of course.
* Make your feature addition or bug fix. Make your specs and stories pass (green).
* Run the suite using multiruby or rvm to ensure cross-version compatibility.
* Cleanup any trailing whitespace in your code (try @whitespace-mode@ in Emacs, or "Remove Trailing Spaces in Document" in the "Text" bundle in Textmate). You can use the `clean_whitespace` Rake task if you like.
* Commit, do not mess with Rakefile. If related to an existing issue in the [tracker](http://github.com/basho/ruby-riak-client/issues), include "Closes #X" in the commit message (where X is the issue number).
* Send a pull request to the Basho repository.

## License & Copyright

Copyright &copy;2012 Casey Rosenthal and Basho Technologies, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
