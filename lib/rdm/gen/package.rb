require 'fileutils'
require 'pathname'

module Rdm
  module Gen
    class Package
      TEMPLATE_NAME      = 'package'
      PACKAGE_LINE_REGEX = /package\s+['"]([\d\w\/\-_]+)['"]/
      CONFIG_LINE_REGEX  = /config\s+([:\w\-_\d]+)/

      class << self
        def generate(package_name:, current_path:, local_path:, locals: {})
          Rdm::Gen::Package.new(package_name, current_path, local_path, locals).create
        end
      end

      def initialize(package_name, current_path, local_path, locals = {})
        @current_path = current_path
        @package_name = package_name
        @local_path   = local_path
        @locals       = locals
        @source       = get_source
      end

      def create
        raise Rdm::Errors::PackageDirExists.new(@local_path) if Dir.exist?(File.join(@source.root_path, @local_path))
        raise Rdm::Errors::PackageNameNotSpecified           if @package_name.nil? || @package_name.empty?
        raise Rdm::Errors::PackageExists                     if @source.packages.keys.include?(@package_name)
                
        package_lines = []
        config_lines  = []
        setup_lines   = []

        rdm_root_file_path = File.join(@source.root_path, Rdm::SOURCE_FILENAME)
        File.open(rdm_root_file_path).each_line do |line|
          case line
          when PACKAGE_LINE_REGEX
            package_lines.push line
          when CONFIG_LINE_REGEX
            config_lines.push line
          when "\n"
            # skip
          else
            setup_lines.push line
          end
        end

        package_lines.push "package \"#{@local_path}\""
        
        File.open(rdm_root_file_path, 'w') do |file|
          file.write setup_lines.join
          file.write("\n\n")
          file.write config_lines.join
          file.write("\n\n")
          file.write package_lines.join
        end

        Rdm::Handlers::TemplateHandler.generate(
          template_name: TEMPLATE_NAME,
          current_path:  @current_path,
          local_path:    @local_path,
          locals:        { package_name: @package_name }.merge(@locals)
        )
      end

      def get_source
        @source ||= Rdm::SourceParser.read_and_init_source(Rdm::SourceLocator.locate(@current_path))
      end
    end
  end
end
