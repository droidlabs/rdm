### RDM (Ruby Dependecy Manager)


[![Build Status](https://api.travis-ci.org/ddd-ruby/rdm.svg?branch=master)](http://travis-ci.org/ddd-ruby/rdm) [![codecov](https://codecov.io/gh/ddd-ruby/rdm/branch/master/graph/badge.svg)](https://codecov.io/gh/ddd-ruby/rdm)


Ruby dependency manager, helps managing local package dependencies.
See sample application in "example" folder.


## Setup
You can initialize a project with `rdm`:

    $ mkdir my_project && rdm init

Alternatively you could manually create the an `Rdm.packages` file with similar content in your existing project:

```ruby
setup do
  role                ENV['RUBY_ENV'] || 'production'
  configs_dir         'configs'
  config_path         ":configs_dir/:config_name/default.yml"
  role_config_path    ":configs_dir/:config_name/:role.yml"
  package_subdir_name 'package'
end

config :database
config :app

package 'server'
package 'application/web'
package 'domain/core'
package 'infrastructure/repository'
```


## Generating new packages

    # see available options
    $ rdm gen.package -h

    # generate commands package in a relative path to root directory
    $ rdm gen.package commands --path core/application/commands


## Example Package.rb

```ruby
package do
  name    'system_bus'
  version '1.0.0'
end

dependency do
  import 'utils'
end

dependency :test do
  import 'repository'
  import 'database'
  import 'events'
end
```


## Rough Idea

`Rdm` positions itself somewhere between Ruby gems and Rails engines. It allows you to define clear boundaries in your application by splitting it up in application-level, framework-agnostic packages. Each package defines in its `Package.rb` file clear dependencies on other packages / gems for each environment.

When you `boot` a package (eg. by loading it in IRB), only defined dependencies are available to you. This is done by letting `Rdm` manage the Ruby-`$LOAD_PATH` behind the scenes for you.

All packages share the same Gemfile, but get access to only explicitly defined subset of gems / packages from the `Package.rb` file

When needed you can ask `Rdm` to programmatically give you dependencies for a particular package and use it. At `DroidLabs` we use this to generate very lightweight Dockerimages with just the necessary dependencies for each application.


## Rules of RDM to structure big Ruby applications

1. define all your gems in `Gemfile` to be lazily loaded, like

```ruby
gem 'sequel',     '4.41.0',  require: false
```
1. name your classes / modules after Rails-established conventions, so files are loaded only on demand, when encountering a new class / module constant (const_missing from ActiveSupport)

1. use a Dependency Injection library with lazy-loading support, we recommend `smart_ioc`


## Loading `Rdm`

Setup RDM in boot.rb or spec_helper.rb or any other initializer. Rdm.init should point to a directory with `Package.rb`-file

```ruby
require 'rdm'
Rdm.init(File.expand_path("../../", __FILE__), :test)
```
