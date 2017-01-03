require 'active_support'
require 'active_support/dependencies'

class Rdm::PackageImporter
  class << self
    # Initialize current package using Package.rb
    # @param package_path [String] Package.rb file path
    # @param group [Optional<String>] Dependency group
    # @return [Rdm::Package] Current package
    def import_file(package_path, group: nil)
      instance.import_file(package_path, group: group)
    end

    # Import package and initialize module
    def import_package(package_name, source:, group: nil)
      instance.import_package(package_name, source: source, group: group)
    end

    def instance
      @instance ||= self.new
    end

    def reset!
      @instance = nil
    end
  end

  # Initialize current package using Package.rb
  # @param package_path [String] Package.rb file path
  # @param group [Optional<String>] Dependency group
  # @return [Rdm::Package] Current package
  def import_file(package_path, group: nil)
    package = Rdm::PackageParser.parse_file(package_path)
    source  = read_and_init_source(package.source)

    # Init Rdm.root based on Rdm.packages directory
    Rdm.root = File.dirname(package.source)

    # Import package and it's dependencies
    import_package(package.name, source: source, group: group.to_s)

    package
  end

  def imported_packages
    @imported_packages ||= []
  end

  def imported_configs
    @imported_configs ||= []
  end

  # Import package and initialize module
  def import_package(package_name, source:, group: nil)
    return imported_packages if imported_packages.include?(package_name.to_s)
    package = source.packages[package_name.to_s]

    if package == nil
      raise "Can't find package with name: #{package_name.to_s}"
    end

    init_package(package, group: group)
    imported_packages << package_name

    # also import local dependencies
    package.local_dependencies(group).each do |dependency|
      import_package(dependency, source: source)
    end

    # also import config dependencies
    package.config_dependencies(group).each do |dependency|
      import_config(dependency, source: source)
    end

    # only after importing dependencies - require package itself
    begin
      require package_name
    rescue LoadError => e
      unless Rdm.settings.silence_missing_package_file
        package_require_path = "#{package_name}/#{package_subdir_name}/#{package_name}.rb"
        puts "WARNING: Can't require package #{package_name}, please make sure that file #{package_require_path} exists and it's valid."
        raise e
      end
    end
    imported_packages
  end

  private

  def source_parser
    Rdm::SourceParser
  end

  def package_subdir_name
    Rdm.settings.package_subdir_name.to_s
  end

  def init_package(package, group:)
    package_dir_name = File.join(package.path, package_subdir_name)
    $LOAD_PATH.push(package_dir_name)

    package.external_dependencies(group).each do |dependency|
      require dependency
    end

    package.file_dependencies(group).each do |file_path|
      require File.join(package.path, file_path)
    end

    if !ActiveSupport::Dependencies.autoload_paths.include?(package_dir_name)
      ActiveSupport::Dependencies.autoload_paths << package_dir_name
    end
  end

  def import_config(config_name, source:)
    return if imported_configs.include?(config_name)
    config = source.configs[config_name.to_s]
    if config == nil
      raise "Can't find config with name: #{config_name.to_s}"
    end
    Rdm.config.load_config(config, source: source)
    imported_configs << config_name
  end

  def read_and_init_source(source_path)
    source_parser.read_and_init_source(source_path)
  end
end
