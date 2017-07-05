module Rdm::SpecRunner
  def self.run(path: nil, package: nil, spec_matcher: nil)
    Rdm::SpecRunner::Runner.new(path: path, package: package, spec_matcher: spec_matcher).run
  end
end