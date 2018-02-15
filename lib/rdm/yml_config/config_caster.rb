require 'morf'

class Rdm::ConfigCaster
  def initialize(envs)
    @envs = envs
  end

  def cast(hash)
    hash[@envs.name] ||= {}
    caster.cast(hash, input_keys: :string, skip_unexpected_attributes: true)
  end
  

  def to_hcast_string(env)
    eval_string = "#{env.type} :#{env.name}, optional: #{env.optional}"
    eval_string += env.is_array? ? ", each: :#{env.children.first.type}" : ""
    eval_string += env.is_hash? ? %Q( do \n  #{env.children.map { |e| to_hcast_string(e) }.join("\n")} \nend) : ""

    eval_string
  end

  private

  def caster
    @caster ||= Class.new
    @caster.include(Morf::Caster)

    @caster.class_eval "attributes do\n #{to_hcast_string(@envs)}\n end"

    @caster
  end
end