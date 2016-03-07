class Web::SampleController
  #inject :sample_service

  def perform
    sample_service.perform
  end

  def sample_service
    Core::SampleService.new
  end
end