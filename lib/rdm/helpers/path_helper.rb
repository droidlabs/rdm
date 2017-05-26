module Rdm
  module Helpers
    module PathHelper
      def package_path(package_name, current_file: nil)
        current_file ||= caller[0].split(':').first

        source = Rdm::SourceParser.read_and_init_source(Rdm::SourceLocator.locate(current_file))

        raise Rdm::Errors::PackageDoesNotExist unless source.packages.keys.include?(package_name.to_s)

        return source.packages.fetch(package_name.to_s).path
      end
    end
  end
end