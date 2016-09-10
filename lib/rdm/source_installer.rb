class Rdm::SourceInstaller
  class << self
    # Install source by locking all it's specs
    def install(source_path)
      source_content = File.open(source_path).read
      source_parser.parse(source_content).package_paths.each do |package_path|
        full_path = File.join(File.dirname(source_path), package_path, Rdm::PACKAGE_FILENAME)
        lock(full_path, source_path: source_path, package_path: package_path)
      end
    end

    # Lock package on installation
    def lock(full_package_path, source_path:, package_path:)
      package_content = File.open(full_package_path).read

      locked = "source \"#{source_path}\"\r\n\r\n"
      locked += package_content

      lock_file = "#{full_package_path}.lock"

      return if File.exist?(lock_file) && File.read(lock_file) == locked

      File.open(lock_file, "w+") do |file|
        file.write(locked)
      end
    rescue Errno::ENOENT
      puts "Can't find package: #{package_path}"
    end

    private
      def source_parser
        Rdm::SourceParser
      end
  end
end
