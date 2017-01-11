class Rdm::ConfigScope
  def initialize(attributes = {})
    @attributes = attributes
  end

  def read_attribute(key)
    @attributes[key.to_s]
  end

  def write_attribute(key, value)
    @attributes[key.to_s] = value
  end

  def method_missing(method_name, *_args)
    read_attribute(method_name)
  end

  def to_h
    @attributes.each_with_object({}) do |(k, v), h|
      h[k] = Rdm::ConfigScope === v ? v.to_h : v
    end
  end
end
