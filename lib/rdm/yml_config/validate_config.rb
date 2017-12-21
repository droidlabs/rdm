class Rdm::ValidateConfig
  attr_accessor :length, :size, :inclusion

  def to_hash
    {
      length:     @length,
      size:       @size,
      inclusion: @inclusion
    }.delete_if {|_, v| v.nil? || v.empty?}
  end
end