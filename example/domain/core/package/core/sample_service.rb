class Core::SampleService
  #inject :sample_repository

  def perform
    sample_repository.perform
  end

  def sample_repository
    Repository::SampleRepository.new
  end
end