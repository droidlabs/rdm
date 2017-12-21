class Rdm::EnvConfig
  module Types
    STRING  = :string
    ARRAY   = :array
    HASH    = :hash
    SYMBOL  = :symbol
    INTEGER = :integer

    ALL = [STRING, ARRAY, HASH, SYMBOL, INTEGER]
  end

  attr_reader :name, :type, :optional, :default, :each

  def initialize(name:, type:, optional: false, default: nil, validates: nil, each: [])
    @name      = name
    @type      = Types::ALL.include?(type) ? type: (raise ArgumentError, "Invalid env type")
    @optional  = !!optional
    @validates = validates || Rdm::ValidateConfig.new
    @each      = each.select {|e| e.is_a?(Rdm::EnvConfig)}
    @default   = default
  end

  def to_hash
    hash = {
      name:      @name,
      type:      @type,
      optional:  @optional,
      default:   @default,
    }.delete_if { |_, v| v.nil? }

    hash[:each]      = @each.map(&:to_hash) if @each.any?
    hash[:validates] = @validates.to_hash   if @validates.to_hash.any?

    hash
  end

  def is_array?
    @type == Types::ARRAY
  end

  def is_hash?
    @type == Types::HASH
  end
end

