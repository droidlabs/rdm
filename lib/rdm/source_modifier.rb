class Rdm::SourceModifier
  PACKAGE_LINE_REGEX = /package\s+['"]([\d\w\/\-_]+)['"]/
  CONFIG_LINE_REGEX  = /config\s+([:\w\-_\d]+)/

  class << self
    def add_package(package_path, root_path)
      Rdm::SourceModifier.new(root_path).add_package(package_path)
    end

    def add_config(config_name, root_path)
      Rdm::SourceModifier.new(root_path).add_config(config_name)
    end
  end

  def initialize(root_path)
    @source_path = File.join(root_path, Rdm::SOURCE_FILENAME)
  end

  def add_package(package_path)
    package_lines = []
    config_lines  = []
    setup_lines   = []
    
    File.open(@source_path).each_line do |line|
      case line
      when PACKAGE_LINE_REGEX
        package_lines.push line
      when CONFIG_LINE_REGEX
        config_lines.push line
      when "\n"
        # DO NOTHING
      else
        setup_lines.push line
      end
    end

    package_lines.push "package \"#{package_path}\""
    
    File.open(@source_path, 'w') do |file|
      file.write setup_lines.join
      file.write("\n\n")
      file.write config_lines.join
      file.write("\n\n")
      file.write package_lines.join
    end
  end

  def add_config(config_name)
    package_lines = []
    config_lines  = []
    setup_lines   = []

    File.open(@source_path).each_line do |line|
      case line
      when PACKAGE_LINE_REGEX
        package_lines.push line
      when CONFIG_LINE_REGEX
        config_lines.push line
      when "\n"
        # DO NOTHING
      else
        setup_lines.push line
      end
    end

    config_lines.push "config :#{config_name}"
    
    File.open(@source_path, 'w') do |file|
      file.write setup_lines.join
      file.write("\n\n")
      file.write config_lines.join
      file.write("\n\n")
      file.write package_lines.join
    end
  end
end