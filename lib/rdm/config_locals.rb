class Rdm::ConfigLocals
  def initialize(locals = {})
    @locals = locals
  end

  def to_s
    @locals
      .map {|key, value| "#{key}: #{value}"}
      .join("\n")
  end
end