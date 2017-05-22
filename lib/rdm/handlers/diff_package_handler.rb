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

        source_path = Rdm::SourceLocator.locate(path)
        @all_packages = Rdm::SourceParser.read_and_init_source(source_path).packages.values
      end

      def handle
        modified_packages = Rdm::Git::DiffManager
          .run(path: path, revision: revision)
          .map { |file| Rdm::Package::Locator.locate(file) rescue nil }
          .map { |path_to_package| Rdm::PackageParser.parse_file(path_to_package).name rescue nil }
          .reject(&:blank?)
          .uniq
        
        return get_dependencies(modified_packages)
          
      rescue Rdm::Errors::GitCommandError => e
        puts e.message
      end

      private
        def get_dependencies(base_packages)
          base_packages.sort!

          new_packages = all_packages
            .select {|p| (p.local_dependencies & base_packages).any?}
            .map(&:name)
          
          extended_dependencies = (base_packages | new_packages).sort
          
          return extended_dependencies if extended_dependencies == base_packages

          get_dependencies(extended_dependencies)
        end
    end
  end
end