module Rdm
  module CLI
    class DependenciesController
      class << self
        def run(package_name:, project_path:, stdout: nil)
          DependenciesController.new(package_name, project_path, stdout).run
        end
      end

      def initialize(package_name, project_path, stdout)
        @package_name = package_name
        @project_path = project_path
        @stdout = stdout || $stdout
      end

      def run
        package_list = Rdm::Handlers::DependenciesHandler.show_names(
          package_name: @package_name,
          project_path: @project_path
        )
        
        package_list.reject! {|pkg| pkg == @package_name}

        if package_list.count > 0
          @stdout.puts "Package `#{@package_name}` dependent on this packages:"
          @stdout.puts package_list.map.with_index { |value, idx| "  #{idx+1}. #{value}" }
        else
          @stdout.puts "Package `#{@package_name}` has no dependencies"
        end

      rescue Rdm::Errors::InvalidParams => e
        @stdout.puts e.message
      rescue Rdm::Errors::SourceFileDoesNotExist => e
        @stdout.puts e.message
      end
    end
  end
end