class Rdm::SourceParser
  class SourceValidationError < StandardError
  end

  class << self
    def read_and_init_source(source_path, stdout: nil)
      Rdm::SourceParser.new(source_path, stdout).read_and_init_source
    end
  end

  attr_accessor :source_path

  def initialize(source_path, stdout)
    @source_path = source_path
    @stdout      = stdout || STDOUT
  end

  # Read source file, parse and init it's packages
  # @param source_path [String] Source file path
  # @return [Rdm::Source] Source
  def read_and_init_source
    source = parse_source_content

    # Setup Rdm
    if block = source.setup_block
      Rdm.setup(&block)
    end
    validate_rdm_settings!

    init_and_set_packages(source)
    source.init_with(packages: packages)
    source
  end

  # Parse source file and return Source object
  # @return [Rdm::Source] Source
  def parse_source_content
    source = Rdm::Source.new(root_path: root_path)
    source.instance_eval(source_content)
    source
  end

  private

  def init_and_set_packages(source)
    source.package_paths.each do |package_path|
      package_full_path = File.join(root_path, package_path)
      if File.exist?(package_full_path)
        package_rb_path        = File.join(package_full_path, Rdm::PACKAGE_FILENAME)
        package                = Rdm::PackageParser.parse_file(package_rb_path)
        packages[package.name] = package
      elsif !settings.silence_missing_package
        raise "Missing package at folder: #{package_full_path}"
      end
    end
  end

  # Make sure that all required settings are in place
  def validate_rdm_settings!
    if settings.read_setting(:role).nil?
      raise SourceValidationError, "Please add `role` setting in Rdm.packages. E.g. \r\n setup do\r\n  role { ENV['RAILS_ENV'] }\r\n end"
    end
    if settings.read_setting(:config_path).nil?
      raise SourceValidationError, "Please add `config_path` setting in Rdm.packages. E.g. \r\n setup do\r\n  config_path :configs_dir/:config_name/default.yml'\r\n end"
    end
  end

  def root_path
    File.dirname(source_path)
  end

  # [String] Source file content
  def source_content
    @source_content ||= File.read(source_path)
  end

  def packages
    @packages ||= {}
  end

  def settings
    Rdm.settings
  end
end
