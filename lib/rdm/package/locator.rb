class Rdm::Package::Locator
  class << self
    def locate(path)
      raise Rdm::Errors::PackageFileDoesNotFound, path if source_present?(path)
      raise Rdm::Errors::SourceFileDoesNotExist,  path if root_reached?(path)
      
      return path if package_present?(path)
      
      locate(File.dirname(path))
    end

    def root_reached?(path)
      File.expand_path(path) == '/'
    end

    def source_present?(path)
      expected_source_file = File.join(path, Rdm::SOURCE_FILENAME)
      
      File.exist?(expected_source_file)
    end

    def package_present?(path)
      expected_package_file = File.join(path, Rdm::PACKAGE_FILENAME)

      File.exist?(expected_package_file)
    end
  end
end