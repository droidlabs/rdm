### RDM (Ruby Dependecy Manager)


[![Build Status](https://travis-ci.org/mindreframer/rdm.svg?branch=feature/better_cli)](http://travis-ci.org/mindreframer/rdm)


Ruby dependency manager, helps managing local package dependencies.
See sample application in "example" folder.


## Setup
1. create Rdm.packages in the root dir of your application
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

1. Use package generator to create new package

    ```ruby
      rdm-generate package server --path=core/server
    ```

1. Setup RDM in boot.rb or spec_helper.rb or any other initializer. Rdm.init should point to the directory where Rdm.packages file is located

    ```ruby
      require 'rdm'
      Rdm.init(File.expand_path("../../", __FILE__), :test)
    ```

1. Run rdm-install in root directory to create Package.rb.lock for each package. You should do that each time you create new package or update existing package dependencies.

1. Go to package directory, create some tests and run them.
