class Rdm::Source
  attr_reader :setup_block, :config_names, :package_paths, :root_path

  def initialize(root_path:)
    @root_path = root_path
    @package_paths = []
  end

  # Set setup block for source
  # @param block [Proc] Setup block
  def setup(&block)
    @setup_block = block
  end

  # Add package to list of known packages
  # @param package_path [String] Package path
  def package(package_path)
    @package_paths << package_path
  end

  # Init source by adding read packages and configs
  # @param value [Hash<String: Rdm::Package>] Hash of packages by it's name
  # @param value [Hash<String: Rdm::Config>] Hash of configs by it's name
  # @return [Hash<String: Rdm::Package>] Hash of packages by it's name
  def init_with(packages:)
    @packages = packages
  end

  # Read initialized packages
  # @return [Hash<String: Rdm::Package>] Hash of packages by it's name
  def packages
    @packages || {}
  end
end
