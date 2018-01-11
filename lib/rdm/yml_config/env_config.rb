class Rdm::EnvConfig
  module Types
    STRING  = :string
    ARRAY   = :array
    HASH    = :hash
    SYMBOL  = :symbol
    INTEGER = :integer

    ALL = [STRING, ARRAY, HASH, SYMBOL, INTEGER]
  end

  attr_reader :name, :type, :optional, :default, :children, :validates

  def initialize(name:, type:, optional: false, default: nil, validates: nil, children: [])
    @name      = name
    @type      = Types::ALL.include?(type) ? type: (raise ArgumentError, "Invalid env type")
    @optional  = !!optional
    @validates = validates || Rdm::ValidateConfig.new
    @children  = children.select {|e| e.is_a?(Rdm::EnvConfig)}
    @default   = default
  end

  def to_hash
    hash = {
      name:      @name,
      type:      @type,
      optional:  @optional,
      default:   @default,
    }.delete_if { |_, v| v.nil? }

    hash[:children]  = @children.map(&:to_hash) if @children.any?
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

