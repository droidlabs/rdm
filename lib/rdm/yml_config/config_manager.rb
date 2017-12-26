require 'yaml'

class Rdm::ConfigManager
  class << self
    def load_config(envs:, path_to_config:)
      instance.config.merge! Rdm::ConfigCaster.new(*envs).cast(YAML.load(File.read(path_to_config)))
    end

    def reset!
      instance.config.clear
    end

    def method_missing(meth, *args, &block)
      instance.send(meth)
    end

    def instance
      @instance ||= new
    end
  end

  def method_missing(meth)
    config.fetch(meth) 
  rescue KeyError
    raise ArgumentError, ":#{meth} configuration was not defined for current package. Add `import '#{meth}'` to your Package.rb file"
  end

  def config
    @config ||= {}
  end
end