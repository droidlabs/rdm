class Web::SampleController
  #inject :sample_service

  def perform
    puts "Web::SampleController called..."
    sample_service.perform
  end

  def sample_service
    Core::SampleService.new
  end
end
