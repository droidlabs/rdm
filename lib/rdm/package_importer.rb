class Rdm::PackageImporter
  class << self
    # Initialize current package using Package.rb
    def import_file(package_path, group: nil)
      if File.directory?(package_path)
        package_path = File.join(package_path, Rdm::PACKAGE_LOCK_FILENAME)
      end
      package_content = File.open(package_path).read
      package = package_parser.parse(package_content)

      source = read_and_init_source(package.source)
      import_package(package.name, packages: source.packages, group: group.to_s)
    end

    # Import package and initialize module
    def import_package(package_name, packages:, imported_packages: [], group: nil)
      return if imported_packages.include?(package_name.to_s)
      package = packages[package_name.to_s]

      if package == nil
        raise "Can't find package with name: #{package_name.to_s}"
      end

      init_package(package, group: group)
      imported_packages << package_name

      # also import local dependencies
      package.local_dependencies(group).each do |dependency|
        import_package(dependency, packages: packages, imported_packages: imported_packages)
      end

      # only after importing dependencies - require package itself
      begin
        require package_name
      rescue LoadError
        if Rdm.settings.raises_missing_package_file_exception
          raise "Can't require package #{package_name}, please create file #{package_name}/lib/#{package_name}.rb"
        end
      end

      imported_packages
    end

    private
      def source_parser
        Rdm::SourceParser
      end

      def package_parser
        Rdm::PackageParser
      end

      def init_package(package, group:)
        $LOAD_PATH.push(File.join(package.path, "lib"))

        package.external_dependencies(group).each do |dependency|
          require dependency
        end
        package.file_dependencies(group).each do |file_path|
          require File.join(package.path, file_path)
        end
      end

      def read_and_init_source(source_path)
        root_path = File.dirname(source_path)
        source_content = File.open(source_path).read
        source = source_parser.parse(source_content)

        # Setup Rdm
        if block = source.setup_block
          Rdm.setup(&block)
        end

        # Parse and set packages
        packages = {}
        source.package_paths.each do |package_path|
          package_full_path = File.join(root_path, package_path)
          package_rb_path = File.join(package_full_path, Rdm::PACKAGE_FILENAME)
          package_content = File.open(package_rb_path).read
          package = package_parser.parse(package_content)
          package.path = package_full_path
          packages[package.name] = package
        end
        source.packages = packages

        source
      end
  end
end