require 'yaml'
class Rdm::ConfigManager

  # Update configuration based on given config file
  # @param config [Rdm::Config] Config entity
  # @return root scope [Rdm::ConfigScope] Updated root scope
  def load_config(config, source:)
    full_default_path = File.join(source.root_path, config.default_path)
    full_role_path = File.join(source.root_path, config.role_path)

    update_using_file(full_default_path, raise_if_missing: true)
    update_using_file(full_role_path, raise_if_missing: false)
    root_scope
  end

  # Update configuration using given path to config file
  # @param config [Hash<String: AnyValue>] Hash with configuration
  # @return root scope [Rdm::ConfigScope] Updated root scope
  def update_using_file(path, raise_if_missing: true)
    if File.exists?(path)
      hash = YAML.load_file(path)
      update_using_hash(hash)
    elsif raise_if_missing
      raise "Config file is not found at path #{path}"
    end
    root_scope
  end

  # Update configuration based on given hash
  # @param config [Hash<String: AnyValue>] Hash with configuration
  # @return root scope [Rdm::ConfigScope] Updated root scope
  def update_using_hash(hash, scope: nil)
    scope ||= root_scope

    hash.each do |key, value|
      if value.is_a?(Hash)
        # Try using existing scope
        child_scope = scope.read_attribute(key)
        if !child_scope || !child_scope.is_a?(Rdm::ConfigScope)
          child_scope = Rdm::ConfigScope.new
        end
        update_using_hash(value, scope: child_scope)
        scope.write_attribute(key, child_scope)
      else
        scope.write_attribute(key, value)
      end
    end
  end

  def method_missing(method_name, *args)
    root_scope.send(method_name, *args)
  end

  private
    def root_scope
      @root_scope ||= Rdm::ConfigScope.new
    end
end