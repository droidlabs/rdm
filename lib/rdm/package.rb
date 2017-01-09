class Rdm::Package
  DEFAULT_GROUP = '_default_'.freeze

  attr_accessor :metadata, :local_dependencies, :external_dependencies, :file_dependencies, :config_dependencies, :path

  def local_dependencies(group = nil)
    fetch_dependencies(@local_dependencies || {}, group)
  end

  def external_dependencies(group = nil)
    fetch_dependencies(@external_dependencies || {}, group)
  end

  def file_dependencies(group = nil)
    fetch_dependencies(@file_dependencies || {}, group)
  end

  def config_dependencies(group = nil)
    fetch_dependencies(@config_dependencies || {}, group)
  end

  # Import local dependency, e.g another package
  def import(dependency)
    @local_dependencies ||= {}
    @local_dependencies[current_group] ||= []
    @local_dependencies[current_group] << dependency
  end

  # General ruby requires, e.g. require another gem
  def require(dependency)
    @external_dependencies ||= {}
    @external_dependencies[current_group] ||= []
    @external_dependencies[current_group] << dependency
  end

  # Require file relative to package, e.g. require root file
  def require_file(file)
    @file_dependencies ||= {}
    @file_dependencies[current_group] ||= []
    @file_dependencies[current_group] << file
  end

  # Import config dependency
  def import_config(dependency)
    @config_dependencies ||= {}
    @config_dependencies[current_group] ||= []
    @config_dependencies[current_group] << dependency
  end

  def package
    yield
  end

  def dependency(group = nil)
    @current_group = group ? group.to_s : nil
    yield
    @current_group = nil
  end

  def source(value = nil)
    exec_metadata :source, value
  end

  def name(value = nil)
    exec_metadata :name, value
  end

  def version(value = nil)
    exec_metadata :version, value
  end

  private

  def current_group
    @current_group || DEFAULT_GROUP
  end

  def fetch_dependencies(groupes, group)
    dependencies = groupes[DEFAULT_GROUP] || []
    dependencies += (groupes[group.to_s] || []) if group
    dependencies
  end

  def exec_metadata(key, value)
    if value.nil?
      @metadata[key]
    else
      @metadata ||= {}
      @metadata[key] = value
    end
  end
end
