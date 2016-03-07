class Rdm::ConfigScope
  def initialize(attributes)
    @attributes = {}
  end

  def read_attribute(key)
    @attributes[key.to_s]
  end

  def write_attribute(key, value)
    @attributes[key.to_s] = value
  end
end