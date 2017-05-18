module Rdm
  module Handlers
    class DiffPackageHandler
      class << self
        def handle(path:, git_point: 'HEAD')
          modified_packages = Rdm::Git::DiffManager
            .run(path: path, git_point: git_point)
            .map { |file| Rdm::Package::Locator.locate(file) rescue nil }
            .map{ |path_to_package| Rdm::PackageParser.parse_file(path_to_package).name rescue nil }
            .reject(&:blank?)
            .uniq
          
          all_packages = Rdm::SourceParser.read_and_init_source(Rdm::SourceLocator.locate(path)).packages.values

          dependent_packages = all_packages.select do |pkg|
            (pkg.local_dependencies & modified_packages).any?
          end
          
          return dependent_packages.map(&:name) | modified_packages
        end
      end
    end
  end
end