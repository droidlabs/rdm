class Rdm::EnvConfigDSL
  attr_reader :data

  module Types
    STRING  = :string
    ARRAY   = :array
    HASH    = :hash
    SYMBOL  = :symbol
    INTEGER = :integer

    ALL = [STRING, ARRAY, HASH, SYMBOL, INTEGER]
  end

  def initialize
    @data = []
  end

  def string(name, opts = {}, &block)
    validations = EnvValidateDSL.new
    validations.instance_exec(&block) if block_given?

    @data.push(
      Rdm::EnvConfig.new(
        name:        name,
        type:        Types::STRING,
        optional:    opts[:optional],
        default:     opts[:default],
        validates:   validations.data
      )
    )
  end

  def symbol(name, opts = {}, &block)
    validations = EnvValidateDSL.new
    validations.instance_exec(&block) if block_given?

    @data.push(
      Rdm::EnvConfig.new(
        name:        name,
        type:        Types::SYMBOL,
        optional:    opts[:optional],
        default:     opts[:default],
        validates:   validations.data
      )
    )
  end

  def integer(name, opts = {}, &block)
    validations = EnvValidateDSL.new
    validations.instance_exec(&block) if block_given?

    @data.push(
      Rdm::EnvConfig.new(
        name:        name,
        type:        Types::INTEGER,
        optional:    opts[:optional],
        default:     opts[:default],
        validates:   validations.data
      )
    )
  end

  def array(name, opts = {}, &block)
    array_values = self.class.new
    array_values.send(opts.fetch(:each), nil, {}, &block)

    @data.push(
      Rdm::EnvConfig.new(
        name:        name,
        type:        Types::ARRAY,
        optional:    opts[:optional],
        default:     opts[:default],
        each:        array_values.data
      )
    )
  end

  def hash(name, opts = {}, &block)
    hash_values = self.class.new
    hash_values.instance_exec(&block)

    @data.push(
      Rdm::EnvConfig.new(
        name:        name,
        type:        Types::HASH,
        optional:    opts[:optional],
        default:     opts[:default],
        each:        hash_values.data
      )
    )
  end

  class EnvValidateDSL
    attr_reader :data

    def initialize
      @data = Rdm::ValidateConfig.new
    end

    def method_missing(name, *args)
      @data.send("#{name}=", *args)
    end
  end
end