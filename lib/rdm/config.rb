class Rdm::Config
  attr_accessor :name, :default_path, :role_path

  def self.build(name:, default_path:, role_path:)
    new.tap do |i|
      i.name         = name
      i.default_path = default_path
      i.role_path    = role_path
    end
  end
end
