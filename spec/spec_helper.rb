require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/.direnv/"
  add_filter "/rdm/templates"
end
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'rdm'
require "byebug"
require "fileutils"

Rdm.setup do
  silence_missing_package_file(true)
end

RSpec.configure do |config|
  config.color = true
end


module SetupHelper
  def clean_tmp
    FileUtils.rm_rf(tmp_dir)
  end

  def fresh_project
    clean_tmp
    FileUtils.mkdir_p(tmp_dir)
    FileUtils.cp_r(example_src, tmp_dir)
  end

  def fresh_empty_project
    clean_tmp
    FileUtils.mkdir_p(empty_project_dir)
  end

  def project_dir
    File.join(tmp_dir, "example")
  end

  def empty_project_dir
    File.join(tmp_dir, "empty_project")
  end

  def tmp_dir
    File.join(File.dirname(__FILE__), "tmp/projects")
  end

  def example_src
    File.join(File.dirname(__FILE__), "../example/")
  end

  def reset_example_project(path:)
    FileUtils.rm_rf(path)
  end

  def initialize_example_project(path: '/tmp/example')
    FileUtils.mkdir_p(path)
    FileUtils.mkdir_p(File.join(path, 'application/web/package/web'))
    FileUtils.mkdir_p(File.join(path, 'domain/core/package/core'))

    File.open(File.join(path, Rdm::SOURCE_FILENAME), 'w') do |f| 
      f.write <<~EOF
        setup do
          package_subdir_name "package"
        end

        package "application/web"
        package "domain/core"
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

    return path
  end
end
