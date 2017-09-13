module Rdm
  module CLI
    class DependenciesController
      class << self
        def run(package_name:, project_path:, stdout: nil)
          new(package_name, project_path, stdout).run
        end
      end

      def initialize(package_name, project_path, stdout)
        @package_name = package_name
        @project_path = project_path
        @stdout = stdout || $stdout
      end

      def run
        @stdout.puts Rdm::Handlers::DependenciesHandler.draw(
          package_name: @package_name,
          project_path: @project_path
        )
      rescue Rdm::Errors::InvalidParams => e
        @stdout.puts e.message
      rescue Rdm::Errors::SourceFileDoesNotExist => e
        @stdout.puts e.message
      rescue Rdm::Errors::PackageHasNoDependencies => e
        @stdout.puts "Package `#{e.message}` has no dependencies"
      rescue Rdm::Errors::PackageDoesNotExist => e
        @stdout.puts "Package `#{e.message}` is not defined"
      end
    end
  end
end