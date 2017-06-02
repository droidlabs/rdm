require "fileutils"

module ExampleProjectHelper
  def reset_example_project(path:)
    FileUtils.rm_rf(path)
  end

  def initialize_example_project(path: '/tmp/example')
    [
      '.rdm/templates/repository/dao/<%=name%>_dao.rb',
      '.rdm/templates/repository/mapper/<%=name%>_mapper.rb',
      '.rdm/templates/repository/repository/<%=name%>_repository.rb',
      '.rdm/templates/repository/views/<%=name%>.html.erb'
    ].each do |template_file|
      FileUtils.mkdir_p(File.join(path, Pathname.new(template_file).parent.to_s))
      File.open(File.join(path, Pathname.new(template_file)), 'w') {|f| f.write "class <%=name%>\nend"}
    end

    FileUtils.mkdir_p(File.join(path, 'configs'))
    FileUtils.mkdir_p(File.join(path, 'application/web/package/web'))
    FileUtils.mkdir_p(File.join(path, 'domain/core/package/core'))
    FileUtils.mkdir_p(File.join(path, 'subsystems/mailing_system/package/mailing_system'))
    FileUtils.mkdir_p(File.join(path, 'subsystems/api/package/api'))

    File.open(File.join(path, 'Gemfile'), 'w') do |f| 
      f.write <<~EOF
        gem 'rdm'
      EOF
    end

    File.open(File.join(path, 'Gemfile.lock'), 'w') do |f| 
      f.write <<~EOF
        gem 'rdm'
      EOF
    end

    File.open(File.join(path, 'Gemfile.lock'), 'w') do |f| 
      f.write <<~EOF
        gem 'rdm'
      EOF
    end

    File.open(File.join(path, Rdm::SOURCE_FILENAME), 'w') do |f| 
      f.write <<~EOF
        setup do
          role                "production"
          configs_dir         "configs"
          config_path         ":configs_dir/:config_name/default.yml"
          role_config_path    ":configs_dir/:config_name/:role.yml"
          package_subdir_name "package"
          compile_path        "/tmp/example_compile"
          compile_ignore_files [
            '.gitignore',
            '.byebug_history',
            '.irbrc',
            '.rspec',
            '*_spec.rb',
            '*.log'
          ]
          compile_add_files [
            'Gemfile',
            'Gemfile.lock'
          ]
        end

        package "application/web"
        package "domain/core"
        package "subsystems/api"
      EOF
    end

    File.open(File.join(path, "application/web", Rdm::PACKAGE_FILENAME), 'w') do |f|
      f.write <<~EOF
        package do
          name "web"
          version "1.0"
        end

        dependency do
          import "core"
        end
      EOF
    end

    File.open(File.join(path, "domain/core", Rdm::PACKAGE_FILENAME), 'w') do |f|
      f.write <<~EOF
        package do
          name "core"
          version "1.0"
        end

        dependency do
        end
      EOF
    end

    File.open(File.join(path, "subsystems/api", Rdm::PACKAGE_FILENAME), 'w') do |f|
      f.write <<~EOF
        package do
          name "api"
          version "1.0"
        end

        dependency do
          import "web"
        end
      EOF
    end

    File.open(File.join(path, "application/web/package/web/", "sample_controller.rb"), 'w') do |f|
      f.write <<~EOF
        class Web::SampleController
          def perform
            sample_service.perform
          end

          def sample_service
            Core::SampleService.new
          end
        end
      EOF
    end

    File.open(File.join(path, "application/web/package/", "web.rb"), 'w') do |f|
      f.write <<~EOF
        require 'active_support'
        require 'active_support/dependencies'
        require 'active_support/core_ext'

        ActiveSupport::Dependencies.autoload_paths << Pathname.new(__FILE__).parent.to_s

        module Web
        end
      EOF
    end

    File.open(File.join(path, "domain/core/package/core/", "sample_service.rb"), 'w') do |f|
      f.write <<~EOF
        class Core::SampleService
          def perform
            puts "Core::SampleService called..."
          end
        end
      EOF
    end

    File.open(File.join(path, "domain/core/package/", "core.rb"), 'w') do |f|
      f.write <<~EOF
        require 'active_support'
        require 'active_support/dependencies'
        require 'active_support/core_ext'

        ActiveSupport::Dependencies.autoload_paths << Pathname.new(__FILE__).parent.to_s

        module Core
        end
      EOF
    end

    File.open(File.join(path, "subsystems/api/package", "api.rb"), 'w') do |f|
      f.write <<~EOF
        require 'active_support'
        require 'active_support/dependencies'
        require 'active_support/core_ext'

        ActiveSupport::Dependencies.autoload_paths << Pathname.new(__FILE__).parent.to_s

        module Api
        end
      EOF
    end

    return path
  end
end