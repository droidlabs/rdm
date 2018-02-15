require 'ostruct'

class Rdm::Utils::Ostruct
  class << self
    def to_recursive_ostruct(hash)
      OpenStruct.new(hash.each_with_object({}) do |(key, val), memo|
        memo[key] = val.is_a?(Hash) ? to_recursive_ostruct(val) : val
      end)
    end
  end
end

