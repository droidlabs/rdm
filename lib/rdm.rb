module Rdm
  SOURCE_FILENAME = 'Rdm.packages'.freeze
  PACKAGE_FILENAME = 'Package.rb'.freeze

  # Utils
  require 'rdm/support/colorize'
  require 'rdm/support/render'
  require 'rdm/support/template'
  require 'rdm/version'

  # CLI part
  require 'rdm/cli/gen_package'
  require 'rdm/cli/init'
  require 'rdm/cli/diff_package'

  # Runtime part
  require 'rdm/config'
  require 'rdm/config_scope'
  require 'rdm/config_manager'
  require 'rdm/errors'
  require 'rdm/package'
  require 'rdm/package_parser'
  require 'rdm/package_importer'
  require 'rdm/settings'
  require 'rdm/source'
  require 'rdm/source_parser'
  require 'rdm/source_locator'
  require 'rdm/git/diff_manager'
  require 'rdm/git/repository_locator'

  # Package part
  require 'rdm/package/locator'

  # Handlers part
  require 'rdm/gen/concerns/template_handling'
  require 'rdm/gen/package'
  require 'rdm/gen/init'
  require 'rdm/handlers/diff_package_handler'

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

    attr_reader :root
  end
end
