require 'yaml'
require 'erb'

class Rdm::PackageEnvManager
  def initialize(data = {}, namespace_list = [])
    @data           = data
    @namespace_list = namespace_list
  end

  def load_hash(hash)
    symbolized_hash = hash.inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end

    @data.merge!(symbolized_hash)
  end

  def load_yaml_file(file_path, env_name)
    return if file_path.to_s.empty?

    path = file_path % { env_name: env_name }

    if File.exists?(path)
      compiled_file = ::ERB.new(File.read(path)).result
      hash = YAML.load(compiled_file)
      load_hash(hash)
    end

    nil
  end

  def namespace_chain(list)
    list.join('.')
  end

  def method_missing(*args)
    method = args.first

    new_namespace = @namespace_list + [method]

    result = @data.fetch(method) { raise StandardError.new("package_config :#{namespace_chain(new_namespace)} is not provided") }

    if result.is_a?(Hash)
      return self.class.new(result, new_namespace)
    else
      return result
    end
  end
end
