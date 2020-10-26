module Rdm
  module CLI
    class CompilePackage
      YES = 'y'

      class << self
        def compile(opts = {})
          Rdm::CLI::CompilePackage.new(**opts).compile
        end
      end

      def initialize(package_name:, project_path:, compile_path: nil, overwrite_directory: nil)
        @package_name        = package_name
        @project_path        = project_path
        @compile_path        = compile_path
        @overwrite_directory = overwrite_directory
      end

      def compile
        Rdm::SourceParser.read_and_init_source(Rdm::SourceLocator.locate(@project_path))

        @overwrite_directory ||= ->() { STDIN.gets.chomp.downcase == YES }
        @compile_path        ||= Rdm.settings.compile_path

        if @package_name.blank?
          puts 'Package name was not specified. Ex: rdm compile.package PACKAGE_NAME'
          return
        end

        if @compile_path.blank?
          puts 'Destination path was not specified. Ex: rdm compile.package package_name --path FOLDER_PATH'
          return
        end

        if Dir.exists?(@compile_path)
          puts "Destination directory exists. Overwrite it? (y/n)"
          return unless @overwrite_directory.call
        end

        compiled_packages = Rdm::Packages::CompilerService.compile(
          package_name: @package_name,
          project_path: @project_path,
          compile_path: @compile_path
        )

        formatted_packages = compiled_packages.sort.map {|pkg| " - #{pkg}"}

        puts <<~EOF

          Compilation for package '#{@package_name}' started.
          The following packages were copied:
          #{formatted_packages.join("\n")}
        EOF

      rescue Rdm::Errors::SourceFileDoesNotExist => e
        puts "Rdm.packages was not found. Run 'rdm init' to create it"
      end
    end
  end
end