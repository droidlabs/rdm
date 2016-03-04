class Web::SampleController
  #inject :sample_service

  def create_something
    sample_service.create_something
  end

  def sample_service
    Core::SampleService.new
  end
end