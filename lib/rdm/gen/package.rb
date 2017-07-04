require 'fileutils'
require 'pathname'

module Rdm
  module Gen
    class Package
      TEMPLATE_NAME = 'package'

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
      end

      def create
        raise Rdm::Errors::PackageDirExists.new(@local_path) if Dir.exist?(File.join(source.root_path, @local_path))
        raise Rdm::Errors::PackageNameNotSpecified           if @package_name.nil? || @package_name.empty?
        raise Rdm::Errors::PackageExists                     if source.packages.keys.include?(@package_name)

        File.open(File.join(source.root_path, Rdm::SOURCE_FILENAME), 'a+') {|f| f.write("\npackage '#{@local_path}'")}

        Rdm::Handlers::TemplateHandler.generate(
          template_name: TEMPLATE_NAME,
          current_path:  @current_path,
          local_path:    @local_path,
          locals: {
            package_name:           @package_name,
            package_name_camelized: Rdm::Utils::StringUtils.camelize(@package_name)
          }.merge(@locals)
        )
      end

      def source
        @source ||= Rdm::SourceParser.read_and_init_source(Rdm::SourceLocator.locate(@current_path))
      end
    end
  end
end
