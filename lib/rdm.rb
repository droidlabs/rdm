module Rdm
  SOURCE_FILENAME = "Rdm.packages"
  PACKAGE_FILENAME = "Package.rb"

  require "rdm/errors"
  require "rdm/support/render"
  require "rdm/support/template"
  require "rdm/settings"
  require "rdm/source"
  require "rdm/source_parser"
  require "rdm/source_locator"
  require "rdm/package"
  require "rdm/package_parser"
  require "rdm/package_importer"
  require "rdm/config"
  require "rdm/config_scope"
  require "rdm/config_manager"
  require "rdm/gen/package"
  require "rdm/gen/init"
  require "rdm/cli/gen_package"
  require "rdm/cli/init"

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
      @config ||= Rdm::ConfigManager.new
    end

    # Setup Rdm's internal settings
    def setup(&block)
      settings.instance_eval(&block) if block_given?
    end

    def root=(value)
      if @root && @root != value
        puts "Rdm has already been initialized and Rdm.root was set to #{@root}"
      end
      @root = value
    end

    def root
      @root
    end
  end
end
