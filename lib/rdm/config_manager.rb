class Rdm::ConfigManager
  # Update configuration based on given config file
  # @param config [Rdm::Config] Config entity
  # @return root scope [Rdm::ConfigScope] Updated root scope
  def load(config)
    update_using_file(config.default_path, raise_if_missing: true)
    update_using_file(config.role_path, raise_if_missing: false)
    root_scope
  end

  def update_using_file(path, raise_if_missing: true)
    if File.exists?(path)
      hash = YAML.load_file(path)
      update_using_hash(hash, scope: root_scope)
    elsif raise_if_missing
      raise "Config file is not found at path #{path}"
    end
  end

  def update_using_hash(hash, scope:)
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

  def root_scope
    @root_scope ||= Rdm::ConfigScope
  end
end