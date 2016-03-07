class Repository::SampleRepository
  def perform
    config = Rdm.config
    puts "WORKS! (#{config.app_name})"
  end
end