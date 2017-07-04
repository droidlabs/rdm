module Rdm::SpecRunner
  def self.run(path: nil, package: nil, spec_mather: nil)
    Rdm::SpecRunner::Runner.new(path: path, package: package, spec_mather: spec_matcher).run
  end
end