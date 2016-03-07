module Rdm
  SOURCE_FILENAME = "Rdm.packages"
  PACKAGE_FILENAME = "Package.rb"
  PACKAGE_LOCK_FILENAME = "#{PACKAGE_FILENAME}.lock"

  require "rdm/settings"
  require "rdm/source"
  require "rdm/source_parser"
  require "rdm/source_installer"
  require "rdm/package"
  require "rdm/package_parser"
  require "rdm/package_importer"

  class << self
    # Initialize current package using Package.rb
    def init(package_path, group = nil)
      Rdm::PackageImporter.import_file(package_path, group: group)
    end

    # Rdm's internal settings
    def settings
      @settings ||= Rdm::Settings.new
    end

    # Rdm's managed configuration
    def config
      @config ||= Rdm::ConfigurationManager
    end

    # Setup Rdm's internal settings
    def setup(&block)
      settings.instance_eval(&block) if block_given?
    end
  end
end