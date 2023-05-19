# Rdm (Ruby Dependency Manager)
[![Code Climate](https://codeclimate.com/github/ddd-ruby/rdm/badges/gpa.svg)](https://codeclimate.com/github/ddd-ruby/rdm)


Ruby dependency manager, helps managing local package dependencies.
See sample application in "example" folder.

## Installation


```bash
# For Ruby >= 3.0
gem install rdm

# For Ruby < 3.0
gem install rdm -v 0.4.20
```

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

- define all your gems in `Gemfile` to be __lazily__ loaded, like `gem 'sequel', '4.41.0', require: false`
- name your classes / modules after Rails-established conventions, so files are loaded only on demand, when encountering a new class / module constant (const_missing from ActiveSupport)

- use a Dependency Injection library with lazy-loading support, we recommend `smart_ioc`


## Loading `Rdm`

Setup RDM in boot.rb or spec_helper.rb or any other initializer. Rdm.init should point to a directory with `Package.rb`-file

```ruby
require 'rdm'
Rdm.init(File.expand_path("../../", __FILE__), :test)
```

### Templates and generators
Rdm has a set of generators using which you can make the creation of template structures automatic. 
By default upon project initialization two generators are available: new package generator gen.package and configuration files generator gen.config. 

**Syntax of the generator is the following:**
```ruby
rdm gen.package #{PACKAGE_NAME} --path #{PATH/TO/PACKAGE}
rdm gen.config #{CONFIG_NAME}
```
To create new package “repository” and place it in the “infrastructure/repository” folder in your app you should type the following command: `rdm gen.package repository --path infrastructure/repository`
You can also change the standard package generator or add custom templates to your project. All available templates are in the **".rdm/templates/:template_name"** folder of your project. The syntax to launch any template generator is the following:
```ruby
rdm gen.template #{TEMPLATE_NAME} --path #{PATH/TO/TEMPLATE}
```
This way if you want to create a structure using “repository” template in the “infrastructure/storage” folder of your app you should type the following command: `rdm gen.template repository --path infrastructure/storage`

When copying the template you can use any variables and helpers methods. In order to get unknown variables that are contained in the templates, the Rdm will show the dialogue window requesting to type in their values. A previously defined variable is "package_subdir_name", it’s value is set in Rdm.packages file. To enter variables to templates a common erb syntax is used:
```ruby
require '<%=name%>_repository'
```
```ruby
class <%= package_name %>
  def initialize
  end
end
```
You can add helpers methods yourself to the **.rdm/helpers/render_helper.rb** and they will be available to use in the templates. 
```ruby
# .rdm/helpers/render_helper.rb
module Rdm
  module RenderHelper
    def camelize(string, uppercase_first_letter = true)
      # some staff
    end
  end
end
```
```ruby
# .rdm/templates/custom_template
class <%= capitalize(package_name) %>
  def initialize
  end
end
```

### Package compiler
Rdm lets you make any package compliance easier, using only dependencies needed for it. Command syntax is the following:
```ruby
rdm compile.package #{PACKAGE_NAME} --path #{PATH/TO/COMPILED/PACKAGE}
```
By default the path value is **‘tmp/:package_name’**, where *:package_name* is changed to the name of the package. This way if you want to comply a ‘web’ package with all it’s dependencies in the '~/dev/web' directory type the following command: `rdm compile.package web --path '~/dev/web'`

### Diff manager
If you have VCS Git on your projects you can use it to get the list of packages that have undergone any changes. The command syntax is the following:
```ruby
rdm git.diff #{REVISION}
```
This way if you want to get a list of packages that have undergone changes compared to the development branch from the master branch, type this command: `rdm git.diff development`

### Dependencies manager
Rdm lets you to create a dependency tree for your packages. Syntax for the command is the following:
```ruby
rdm gen.deps #{PACKAGE_NAME}
```
This way if you want to display recursive list of dependencies for the ‘server’ package type in the following:
`rdm gen.deps server`
Values listed in the parentheses to the right of the package contain information on groups that have this package in them.


## Examples

- [small dummy application](/example)