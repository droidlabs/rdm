class Rdm::ConfigCaster
  def initialize(*envs)
    @envs = envs

  end

  def cast(hash)
    @caster.cast(hash)
  end
  

  def to_hcast_string(env)
    base_string = "#{env.type} :#{env.name}, optional: #{env.optional}"

    each_string = env.is_array? ? ", each: :#{env.each.first.type}" : ""

    child_string = env.is_hash? ? %Q( do \n  #{env.each.map { |e| to_hcast_string(e) }.join("\n")} \nend) : ""

    base_string + each_string + child_string
  end

  private

  def caster
    @caster ||= Class.new(HCast::Caster).class_eval do
      attributes do
        envs.map {|e| to_hcast_string(e)}.join("\n")
      end
    end
  end
end