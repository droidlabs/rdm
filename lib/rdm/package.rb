class Rdm::Package
  DEFAULT_GROUP = '_default_'.freeze

  attr_accessor :metadata, :local_dependencies, :external_dependencies, :file_dependencies, :config_dependencies, :path
  attr_reader :environments

  def local_dependencies(group = nil)
    fetch_dependencies(@local_dependencies || {}, group)
  end

  def external_dependencies(group = nil)
    fetch_dependencies(@external_dependencies || {}, group)
  end

  def file_dependencies(group = nil)
    fetch_dependencies(@file_dependencies || {}, group)
  end

  def local_dependencies_with_groups
    return {} if @local_dependencies.nil?
    @local_dependencies.each_with_object(
      Hash.new { |h,k| h[k]=[] }
    ) do|(k,v), h| 
      v.map { |t| h[t] << k }
    end
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

  def ==(other_package)
    return false if other_package.class != self.class

    other_package.name == name
  end

  def set_environments(&block)
    environments.children = Rdm::EnvConfigDSL.new.instance_exec(&block) if block_given?
  end

  def environments
    @environments ||= Rdm::EnvConfig.new(
      name:     name,
      type:     Rdm::EnvConfig::Types::HASH,
      optional: false
    )
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
