class Rdm::SpecRunner::InputParams
  attr_accessor :package_name, :spec_matcher, :run_all
  def initialize(argv)
    @package_name = argv[0].to_s unless argv[0].nil?
    @spec_matcher = argv[1].to_s unless argv[1].nil?
    @run_all      = !@package_name
  end
end