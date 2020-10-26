module Rdm
  SOURCE_FILENAME = 'Rdm.packages'.freeze
  PACKAGE_FILENAME = 'Package.rb'.freeze

  # Utils
  require 'rdm/utils/render_util'
  require 'rdm/utils/string_utils'
  require 'rdm/utils/file_utils'
  require 'rdm/version'

  # CLI part
  require 'rdm/cli/gen_package'
  require 'rdm/cli/compile_package'
  require 'rdm/cli/init'
  require 'rdm/cli/diff_package'
  require 'rdm/cli/template_generator'
  require 'rdm/cli/dependencies_controller'
  require 'rdm/cli/config'
  require 'rdm/cli/diff_spec_runner.rb'

  # Runtime part
  require 'rdm/config'
  require 'rdm/config_scope'
  require 'rdm/config_manager'
  require 'rdm/package_env_manager'
  require 'rdm/errors'
  require 'rdm/package'
  require 'rdm/package_parser'
  require 'rdm/package_importer'
  require 'rdm/settings'
  require 'rdm/source'
  require 'rdm/source_parser'
  require 'rdm/source_locator'
  require 'rdm/git/diff_manager'
  require 'rdm/git/diff_command'
  require 'rdm/git/repository_locator'
  require 'rdm/config_locals'
  require 'rdm/source_modifier'

  # Package part
  require 'rdm/packages/compiler_service'
  require 'rdm/packages/locator'

  # Handlers part
  require 'rdm/gen/package'
  require 'rdm/gen/init'
  require 'rdm/gen/config'
  require 'rdm/handlers/diff_package_handler'
  require 'rdm/handlers/template_handler'
  require 'rdm/handlers/dependencies_handler'

  require 'rdm/helpers/path_helper'

  require 'rdm/templates/template_renderer'
  require 'rdm/templates/template_detector'

  # Spec runner
  require 'rdm/spec_runner'
  require 'rdm/spec_runner/command_generator'
  require 'rdm/spec_runner/command_params'
  require 'rdm/spec_runner/package_fetcher'
  require 'rdm/spec_runner/runner'
  require 'rdm/spec_runner/view'
  require 'rdm/spec_runner/spec_filename_matcher'

  extend Rdm::Helpers::PathHelper

  class << self
    # Initialize current package using Package.rb
    def init(package_path, group = nil, stdout: $stdout)
      @stdout = stdout

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

    # Rdm's managed configuration
    def env
      @env ||= Rdm::PackageEnvManager.new
    end

    # Setup Rdm's internal settings
    def setup(&block)
      settings.instance_eval(&block) if block_given?
    end

    def root=(value)
      if @root && @root != value
        @stdout.puts "Rdm has already been initialized and Rdm.root was set to #{@root}"
      end
      @root = value
    end

    def root(path = nil)
      return @root if @root

      if path
        @root = Rdm::SourceLocator.locate(path)
      end

      @root
    end

    def root_dir
      if !root
        raise ArgumentError, "Rdm.root is not initialized. Run Rdm.root(ANY_PROJECT_FILE_PATH) to init it"
      end

      File.dirname(root)
    end
  end
end
