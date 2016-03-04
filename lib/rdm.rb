module Rdm
  SOURCE_FILENAME = "Rdm.packages"
  PACKAGE_FILENAME = "Package.rb"
  PACKAGE_LOCK_FILENAME = "#{PACKAGE_FILENAME}.lock"

  require "rdm/source"
  require "rdm/source_parser"
  require "rdm/source_installer"
  require "rdm/package"
  require "rdm/package_parser"
  require "rdm/package_importer"

  class Settings
    # Default settings
    def initialize
      raises_missing_package_file_exception(true)
    end

    def raises_missing_package_file_exception(value = nil)
      exec_setting :raises_missing_package_file_exception, value
    end

    def exec_setting(key, value)
      if value.nil?
        @settings[key]
      else
        @settings ||= {}
        @settings[key] = value
      end
    end
  end

  class << self
    # Initialize current package using Package.rb
    def init(package_path, group = nil)
      Rdm::PackageImporter.import_file(package_path, group: group)
    end

    # Rdm's internal settings
    def settings
      @settings ||= Settings.new
    end

    # Setup Rdm's internal settings
    def setup(&block)
      puts "setup rdm settings"
      settings.instance_eval(&block) if block_given?
    end
  end
end