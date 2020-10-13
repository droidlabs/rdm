class Rdm::SpecRunner::CommandParams
  attr_accessor :package_name, :package_path, :spec_matcher, :spec_count, :command, :exitstatus

  def success?
    @exitstatus == 0
  end
end