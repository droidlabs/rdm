# Rdm (Ruby Dependecy Manager)
[![Build Status](https://travis-ci.org/ddd-ruby/rdm.png)](https://travis-ci.org/ddd-ruby/rdm)
[![Code Climate](https://codeclimate.com/github/ddd-ruby/rdm/badges/gpa.svg)](https://codeclimate.com/github/ddd-ruby/rdm)
[![codecov](https://codecov.io/gh/ddd-ruby/rdm/branch/master/graph/badge.svg)](https://codecov.io/gh/ddd-ruby/rdm)
[![Dependency Status](https://gemnasium.com/ddd-ruby/rdm.png)](https://gemnasium.com/ddd-ruby/rdm)


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

- define all your gems in `Gemfile` to be __lazily__ loaded, like `gem 'sequel', '4.41.0', require: false`
- name your classes / modules after Rails-established conventions, so files are loaded only on demand, when encountering a new class / module constant (const_missing from ActiveSupport)

- use a Dependency Injection library with lazy-loading support, we recommend `smart_ioc`


## Loading `Rdm`

Setup RDM in boot.rb or spec_helper.rb or any other initializer. Rdm.init should point to a directory with `Package.rb`-file

```ruby
require 'rdm'
Rdm.init(File.expand_path("../../", __FILE__), :test)
```


## Examples

- [small dummy application](/example)

## Features

### Templates and generators

Rdm имеет набор генераторов, с помощью которых вы можете автоматизировать создание шаблонных структур.

По-умолчанию, при инициализации проекта доступен генератор новых пакетов `gen.package` и генератор конфигурационных файлов `gen.config`. Синтаксис генератора 
выглядит следующим образом:
```bash
rdm gen.package #{PACKAGE_NAME} --path #{PATH/TO/PACKAGE}
rdm gen.config #{CONFIG_NAME}
```
Чтобы создать новый пакет "repository" и разместить его в папке "infrastructure/repository" вашего приложения, вам нужно набрать следующую команду:
```bash
rdm gen.package repository --path infrastructure/repository
```

Вы так же можете изменять стандартный генератор пакетов или добавлять кастомные шаблоны в своей проект. Все доступные для использования шаблоны лежат в папке ".rdm/templates/:template_name" вашего проекта. Синтаксис для вызова произвольного генератора шаблонов выглядит следующим образом:
```bash
rdm gen.template #{TEMPLATE_NAME} --path #{PATH/TO/TEMPLATE}
```

Таким образом, если вы хотите создать структуру по шаблону "repository" в папке "infrastructure/storage" вашего приложения наберите следующую команду
```bash
rdm gen.template repository --path infrastructure/storage
```

При копировании шаблона вы можете использовать произвольные переменные и вспомогательные методы. 
Чтобы узнать неизвестные переменные, содержащихся в шаблонах, Rdm выведет диалоговое окно с просьбой указать их значения. Заранее объявленными переменными является "package_subdir_name", ее значение указывается в Rdm.packages файле. Для вставки переменных в шаблоны используется обычный erb синтаксис:
```rb
require '<%=name%>_repository'

class <%= package_name %>
  def initialize
  end
end
```
Вспомогательные методы вы можете добавить самостоятельно в файл .rdm/helpers/render_helper.rb и они будут доступны для использования в шаблонах.
```rb
# .rdm/helpers/render_helper.rb
module Rdm
  module RenderHelper
    def camelize(string, uppercase_first_letter = true)
      # some staff
    end
  end
end

# .rdm/templates/custom_template
class <%= capitalize(package_name) %>
  def initialize
  end
end
```

### Package compiler

Rdm позволяет делать облегченную сборку для произвольного пакета, используя только необходимые для него зависимости. Синтаксис команды выглядит следующим образом:
```bash
rdm compile.package #{PACKAGE_NAME} --path #{PATH/TO/COMPILED/PACKAGE}
```
По умолчанию значение пути задано как 'tmp/:package_name', где :package_name подменяется на название пакета.
Таким образом, если вы хотите собрать пакет 'web' со всеми его зависимостями в директорию '~/dev/web', наберите следующую команду:
```bash
rdm compile.package web --path '~/dev/web'
```

### Diff manager

Если вы используете VCS Git в своих проектах, то с ее помощью вы можете получить список пакетов, в которых произошли какие-либо изменения. Синтаксис команды выглядит следующим образом:
```bash
rdm git.diff #{REVISION}
```
Таким образом, если вы хотите получить список пакетов, содержащих изменения относительно ветки development из ветки master, наберите команду 
```bash
rdm git.diff development
```

### Dependencies manager

Rdm позволяет строит дерево зависимостей по своим пакетам. Синтаксис команды выглядит следующим образом:
```bash
rdm gen.deps #{PACKAGE_NAME}
```
Таким образом, если вы хотите вывести рекурсивный список зависимостей для пакета 'server', наберите команду 
```bash
rdm gen.deps server
```
Значения, перечисленные в круглых скобках справа от пакета содержат информацию о группах, в которые входит пакет.

