class Core::SampleService
  #inject :sample_repository

  def create_something
    sample_repository.create_something
  end

  def sample_repository
    Repository::SampleRepository.new
  end
end