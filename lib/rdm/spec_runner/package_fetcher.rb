class Rdm::SpecRunner::PackageFetcher
  def initialize(path)
    @app_path = path
  end

  def packages
    Rdm::SourceParser.read_and_init_source(rdm_packages_path).packages
  end

  def rdm_packages_path
    Rdm::SourceLocator.locate(@app_path)
  end
end