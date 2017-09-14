class Rdm::Gen::Config
  TEMPLATE_NAME      = 'configs'
  PACKAGE_LINE_REGEX = /package\s+['"]([\d\w\/\-_]+)['"]/
  CONFIG_LINE_REGEX  = /config\s+([:\w\-_\d]+)/

  def self.generate(config_name:, current_path:, config_data: {})
    Rdm::Gen::Config.new(config_name, current_path, config_data = {}).generate
  end

  def initialize(config_name, current_path, config_data)
    @current_path = current_path
    @config_name  = config_name
    @source       = get_source

    @config_locals  = Rdm::ConfigLocals.new(config_data)
  end

  def generate
    @locals = {
      config_name:      @config_name,
      config_locals:    @config_locals,
      config_path:      config_path(@config_name),
      role_config_path: role_config_path(@config_name)
    }

    generated_files = Rdm::Handlers::TemplateHandler.generate(
      current_path:       @current_path,
      locals:             @locals,
      template_name:      TEMPLATE_NAME,
      local_path:         './'
    )

    package_lines = []
    config_lines  = []
    setup_lines   = []

    rdm_root_file_path = File.join(@source.root_path, Rdm::SOURCE_FILENAME)
    File.open(rdm_root_file_path).each_line do |line|
      case line
      when PACKAGE_LINE_REGEX
        package_lines.push line
      when CONFIG_LINE_REGEX
        config_lines.push line
      else
        setup_lines.push line
      end
    end

    config_lines.push "config :#{@config_name}"
    
    File.open(rdm_root_file_path, 'w') do |file|
      file.write setup_lines.join
      file.write config_lines.join
      file.write("\n\n")
      file.write package_lines.join
    end
    
    generated_files
  end

  private 

  def get_source
    @source ||= Rdm::SourceParser.read_and_init_source(Rdm::SourceLocator.locate(@current_path))
  end

  def config_path(config_name)
    Rdm.settings.read_setting(
      :config_path, 
      vars: { 
        config_name: config_name
      }
    )
  end

  def role_config_path(config_name)
    Rdm.settings.read_setting(
      :role_config_path, 
      vars: { 
        config_name: config_name
      }
    )
  end
end