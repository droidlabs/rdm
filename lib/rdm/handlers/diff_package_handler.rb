module Rdm
  module Handlers
    class DiffPackageHandler
      class << self
        def handle(path:, revision: 'HEAD')
          return Rdm::Handlers::DiffPackageHandler.new(path: path, revision: revision).handle
        end
      end

      attr_reader :path, :revision, :all_packages
      def initialize(path:, revision:)
        @path     = path
        @revision = revision

        source_path   = Rdm::SourceLocator.locate(path)
        @all_packages = Rdm::SourceParser.read_and_init_source(source_path).packages.values
      end

      def handle
        @revision = 'HEAD' if @revision.nil? || @revision.empty?

        modified_packages = Rdm::Git::DiffManager
          .run(path: path, revision: revision)
          .reject { |file| file.include?(Rdm::Gen::Init::LOCAL_TEMPLATES_PATH) }
          .map { |file| Rdm::Packages::Locator.locate(file) rescue nil }
          .map { |path_to_package| Rdm::PackageParser.parse_file(path_to_package).name rescue nil }
          .reject(&:blank?)
          .uniq

        return get_dependencies(modified_packages) || []
      end

      private
        def get_dependencies(base_packages)
          base_packages.sort!

          new_packages = all_packages
            .select {|p| (p.local_dependencies & base_packages).any?}
            .map(&:name)
          
          extended_dependencies = (base_packages | new_packages).sort
          
          return extended_dependencies if extended_dependencies == base_packages

          get_dependencies(extended_dependencies) || []
        end
    end
  end
end