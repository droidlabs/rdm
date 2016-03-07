class Rdm::ConfigScope
  def initialize(attributes = {})
    @attributes = {}
  end

  def read_attribute(key)
    @attributes[key.to_s]
  end

  def write_attribute(key, value)
    @attributes[key.to_s] = value
  end

  def method_missing(method_name, *args)
    read_attribute(method_name)
  end
end