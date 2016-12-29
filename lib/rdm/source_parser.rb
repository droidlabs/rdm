class Rdm::SourceParser
  class SourceValidationError < StandardError
  end

  class << self
    def read_and_init_source(source_path)
      Rdm::SourceParser.new(source_path).read_and_init_source
    end
  end

  attr_accessor :source_path

  def initialize(source_path)
    @source_path = source_path
  end


  # Read source file, parse and init it's packages and configs
  # @param source_path [String] Source file path
  # @return [Rdm::Source] Source
  def read_and_init_source
    source = parse(source_content, root_path: root_path)

    # Setup Rdm
    if block = source.setup_block
      Rdm.setup(&block)
    end
    validate_rdm_settings!

    init_and_set_packages(source)
    init_and_set_configs(source)
    source.init_with(packages: packages, configs: configs)
    source
  end

  private

  def init_and_set_packages(source)
    source.package_paths.each do |package_path|
      package_full_path = File.join(root_path, package_path)
      if File.exists?(package_full_path)
        package_rb_path        = File.join(package_full_path, Rdm::PACKAGE_FILENAME)
        package_content        = File.read(package_rb_path)
        package                = package_parser.parse(package_content)
        package.path           = package_full_path
        packages[package.name] = package
      elsif !settings.silence_missing_package
        raise "Missing package at folder: #{package_full_path}"
      end
    end
  end

  def init_and_set_configs(source)
    source.config_names.each do |config_name|
      default_path         = settings.read_setting(:config_path, vars: {config_name: config_name})
      role_path            = settings.read_setting(:role_config_path, vars: {config_name: config_name})
      config               = Rdm::Config.new
      config.default_path  = default_path
      config.role_path     = role_path
      config.name          = config_name
      configs[config_name] = config
    end
  end

  # Parse source file and return Source object
  # @param source_content [String] Source file content
  # @return [Rdm::Source] Source
  def parse(source_content, root_path: nil)
    source = Rdm::Source.new(root_path: root_path)
    source.instance_eval(source_content)
    source
  end

  def root_path
    File.dirname(source_path)
  end

  def source_content
    File.read(source_path)
  end

  # Make sure that all required settings are in place
  def validate_rdm_settings!
    if settings.read_setting(:role).nil?
      raise SourceValidationError.new(
        "Please add `role` setting in Rdm.packages. E.g. \r\n setup do\r\n  role { ENV['RAILS_ENV'] }\r\n end"
      )
    end
    if settings.read_setting(:config_path).nil?
      raise SourceValidationError.new(
        "Please add `config_path` setting in Rdm.packages. E.g. \r\n setup do\r\n  config_path :configs_dir/:config_name/default.yml'\r\n end"
      )
    end
  end

  def packages
    @packages ||= {}
  end

  def configs
    @configs ||= {}
  end

  def settings
    Rdm.settings
  end

  def package_parser
    Rdm::PackageParser
  end
end
