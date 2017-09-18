class Rdm::SourceModifier
  PACKAGE_LINE_REGEX = /package\s+['"]([\d\w\/\-_]+)['"]/
  CONFIG_LINE_REGEX  = /config\s+([:\w\-_\d]+)/
  RDM_CONTENT_SPACES = "\n\n"

  class << self
    def add_package(package_path, root_path)
      Rdm::SourceModifier.new(root_path).add_package(package_path)
    end

    def add_config(config_name, root_path)
      Rdm::SourceModifier.new(root_path).add_config(config_name)
    end
  end

  def initialize(root_path)
    @source_path   = File.join(root_path, Rdm::SOURCE_FILENAME)
    @package_lines = []
    @config_lines  = []
    @setup_lines   = []
  end

  def add_package(package_path)
    rebuild_file do
      @package_lines.push "package \"#{package_path}\""
    end
  end

  def add_config(config_name)
    rebuild_file do
      @config_lines.push "config :#{config_name}"
    end
  end

  private

  def rebuild_file
    File.open(@source_path).each_line do |line|
      case line
      when PACKAGE_LINE_REGEX
        @package_lines.push line
      when CONFIG_LINE_REGEX
        @config_lines.push line
      when "\n"
        # DO NOTHING
      else
        @setup_lines.push line
      end
    end

    yield 
    
    File.open(@source_path, 'w') do |file|
      file.write @setup_lines.join
      file.write(RDM_CONTENT_SPACES)

      file.write @config_lines.join
      file.write(RDM_CONTENT_SPACES)

      file.write @package_lines.join
    end

    @package_lines = []
    @config_lines  = []
    @setup_lines   = []

    nil
  end
end