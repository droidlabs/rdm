class Rdm::Source
  attr_accessor :setup_block, :config_names, :package_paths, :packages

  # Set setup block for source
  # @param block [Proc] Setup block
  def setup(&block)
    self.setup_block = block
  end

  # Add config to list of known configs
  # @param config_name [String] Config name
  def config(config_name)
    self.config_names ||= []
    self.config_names << config_name
  end

  # Add package to list of known packages
  # @param package_path [String] Package path
  def package(package_path)
    self.package_paths ||= []
    self.package_paths << package_path
  end
end