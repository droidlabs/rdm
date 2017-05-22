require "fileutils"

module ExampleProjectHelper
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