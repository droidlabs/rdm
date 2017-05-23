module Rdm
  module CLI
    class CompilePackage
      YES = 'y'

      class << self
        def compile(opts = {})
          Rdm::CLI::CompilePackage.new(opts).compile
        end
      end

      attr_reader :compile_path, :overwrite_directory, :package_name, :project_path
      def initialize(package_name:, project_path:, compile_path: nil, overwrite_directory: nil)
        @package_name        = package_name
        @project_path        = project_path
        @compile_path        = compile_path
        @overwrite_directory = overwrite_directory || ->() { STDIN.gets.chomp.downcase == YES }
      end

      def compile
        begin
          init_rdm!(project_path)
      
          @compile_path ||= Rdm.settings.compile_path
          check_preconditions!
          check_directory_exists!(compile_path)
        rescue Rdm::Errors::InvalidParams => e
          puts e.message
          return
        rescue Rdm::Errors::PackageDirExists => e
          puts "Compile directory exists. Overwrite it? (y/n)"
          return if !overwrite_directory.call
        rescue Rdm::Errors::SourceFileDoesNotExist => e
          puts "Source file doesn't exist. Type 'rdm init' to create Rdm.packages"
          return
        end

        compiled_packages = Rdm::Packages::Services::Compiler.compile(
          package_name: package_name,
          project_path: project_path,
          compile_path: compile_path
        )

        puts <<~EOF
          The following packages were successfully compiled:
          #{compiled_packages.map(&:capitalize).join("\n")}
        EOF
      end

      private 
        def check_preconditions!
          raise Rdm::Errors::InvalidParams, 'Package name was not specified!' if package_name.blank?
          raise Rdm::Errors::InvalidParams, 'Compile path was not specified!' if compile_path.blank?
        end

        def check_directory_exists!(path)
          raise Rdm::Errors::PackageDirExists, "" if Dir.exists?(path)
        end

        def init_rdm!(path)
          Rdm::SourceParser.read_and_init_source(
            Rdm::SourceLocator.locate(path)
          )
        end
    end
  end
end