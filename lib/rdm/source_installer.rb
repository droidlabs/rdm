class Rdm::SourceInstaller
  class << self
    # Install source by locking all it's specs
    def install(source_path)
      source_content = File.open(source_path).read
      source_parser.parse(source_content).each do |package_path|
        full_path = File.join(File.dirname(source_path), package_path, Rdm::PACKAGE_FILENAME)
        lock(full_path, source_path)
      end
    end

    # Lock package on installation
    def lock(package_path, source_path)
      package_content = File.open(package_path).read

      locked = "source \"#{source_path}\"\r\n\r\n"
      locked += package_content

      File.open("#{package_path}.lock", "w+").write(locked)
    end

    private
      def source_parser
        Rdm::SourceParser
      end
  end
end