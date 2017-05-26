module Rdm
  module CLI
    class CompilePackage
      YES = 'y'

      class << self
        def compile(opts = {})
          Rdm::CLI::CompilePackage.new(opts).compile
        end
      end

      attr_accessor :compile_path, :overwrite_directory, :package_name, :project_path
      def initialize(package_name:, project_path:, compile_path: nil, overwrite_directory: nil)
        @package_name        = package_name
        @project_path        = project_path
        @compile_path        = compile_path
        @overwrite_directory = overwrite_directory || ->() { STDIN.gets.chomp.downcase == YES }
      end

      def compile
        Rdm::SourceParser.read_and_init_source(Rdm::SourceLocator.locate(project_path))

        compile_path ||= Rdm.settings.compile_path

        if package_name.blank?
          puts 'Package name was not specified!'
          return
        end

        if compile_path.blank?
          puts 'Compile path was not specified!'
          return
        end

        if Dir.exists?(compile_path)
          puts "Compile directory exists. Overwrite it? (y/n)"
          return unless overwrite_directory.call
        end

        compiled_packages = Rdm::Packages::CompilerService.compile(
          package_name: package_name,
          project_path: project_path,
          compile_path: compile_path
        )

        puts <<~EOF
          The following packages were successfully compiled:
          #{compiled_packages.map(&:capitalize).join("\n")}
        EOF

      rescue Rdm::Errors::SourceFileDoesNotExist => e
        puts "Source file doesn't exist. Type 'rdm init' to create Rdm.packages"
      end
    end
  end
end