class Rdm::Gen::Config
  TEMPLATE_NAME = 'configs'

  def self.generate(config_name:, current_path:, config_data: {})
    Rdm::Gen::Config.new(config_name, current_path, config_data = {}).generate
  end

  def initialize(config_name, current_path, config_data)
    @current_path = current_path
    @config_name  = config_name

    @config_locals  = Rdm::ConfigLocals.new(config_data)
  end

  def generate
    source(@current_path)

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

    File.open(source_file(@current_path), 'a+') {|f| f.write("\nconfig :#{@config_name}")}
    
    generated_files
  end

  private 

  def source_file(path)
    @source_file ||= Rdm::SourceLocator.locate(path)
  end

  def source(path)
    @source ||= Rdm::SourceParser.read_and_init_source(source_file(path))
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