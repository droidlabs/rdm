class Rdm::PackageParser
  class << self
    def parse_file(package_path)
      if File.directory?(package_path)
        package_path = File.join(package_path, Rdm::PACKAGE_FILENAME)
      end
      package_content = File.read(package_path)
      package         = parse(package_content)
      package.path    = File.dirname(package_path)
      package.source(source_path(package_path))

      package
    end

    private

    def parse(package_content)
      spec = Rdm::Package.new
      spec.instance_eval(package_content)
      spec
    end

    def source_path(path)
      Rdm::SourceLocator.locate(path)
    end
  end
end
