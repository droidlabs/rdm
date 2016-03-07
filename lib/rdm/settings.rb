class Rdm::Settings
  SETTING_KEYS = [
    :role, :raises_missing_package_file_exception, :package_subdir_name,
    :configs_dir, :config_path, :role_config_path
  ]

  SETTING_VARIABLES = [:role, :configs_dir, :config_path, :role_config_path]

  # Default settings
  def initialize
    raises_missing_package_file_exception(true)
    package_subdir_name("package")
    configs_dir('configs')
    config_path(':configs_dir/:config/default.yml')
    role_config_path(':configs_dir/:config/:role.yml')
  end

  SETTING_KEYS.each do |key|
    define_method(key) do |value = nil|
      fetch_setting key, value
    end
  end

  def fetch_setting(key, value = nil)
    if value.nil?
      read_setting(key)
    else
      write_setting(key, value)
    end
  end

  def read_setting(key, vars: {})
    value = @settings[key.to_s]
    if value.is_a?(Proc)
      value.call
    elsif value.is_a?(String)
      replace_variables(value, except: key, additional_vars: vars)
    else
      value
    end
  end

  private
    def write_setting(key, value)
      @settings ||= {}
      @settings[key.to_s] = value
    end

    def replace_variables(value, except: nil, additional_vars: {})
      variables_keys = SETTING_VARIABLES - [except.to_sym]
      additional_vars.each do |key, variable|
        if value.match(":#{key.to_s}")
          value.gsub!(":#{key.to_s}", variable)
        end
      end
      variables_keys.each do |key|
        if value.match(":#{key}")
          value.gsub!(":#{key}", read_setting(key))
        end
      end
      value
    end
end