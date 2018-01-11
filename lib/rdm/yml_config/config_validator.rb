require 'attr_validator'

class Rdm::ConfigValidator
  def initialize(env_config)
    @env_config = env_config
  end

  def validate!(hash_config)
    dto = OpenStruct.new(hash_config)

    if @env_config.is_hash?
      @env_config.children.each do |subconfig|
        self.class.new(subconfig).validate!(dto.send(@env_config.name).to_h)
      end
    elsif @env_config.is_array?
      dto.send(@env_config.name).each do |el|
        array_dto = OpenStruct.new(@env_config.name => el)
        validator(@env_config.name, @env_config.children.first.validates.to_hash).validate!(array_dto)
      end
    else
      validator(@env_config.name, @env_config.validates.to_hash).validate!(dto)
    end

    dto
  rescue AttrValidator::Errors::ValidationError => e
    raise ArgumentError, e.message
  end

  private

  def validator(name, env_config)
    return @validator if @validator

    validator_class = Class.new
    validator_class.include(AttrValidator::Validator)

    validator_class.class_eval to_attr_validator_string(name, env_config)

    @validator = validator_class.new
  end

  def to_attr_validator_string(name, validates)
    validates_string = []

    validates.each do |key, value|
      validates_string.push "validates :#{name}, #{key}: #{value}"
    end

    validates_string.join("\n")
  end
end