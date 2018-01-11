class Rdm::ValidateConfig
  def initialize
    @data = {}
  end

  def method_missing(method, *args, &block)
    @data[method] = args.first
  end

  def to_hash
    @data
  end
end