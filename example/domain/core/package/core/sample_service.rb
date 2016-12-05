class Core::SampleService
  #inject :sample_repository

  def perform
    puts "Core::SampleService called..."
    sample_repository.perform
  end

  def sample_repository
    Repository::SampleRepository.new
  end
end
