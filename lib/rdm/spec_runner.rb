module Rdm::SpecRunner
  def self.run(
    path:                  nil, 
    package:               nil, 
    spec_matcher:          nil, 
    show_missing_packages: nil, 
    skipped_packages:      []
  )
    Rdm::SpecRunner::Runner.new(
      path:                  path, 
      package:               package, 
      spec_matcher:          spec_matcher, 
      show_missing_packages: show_missing_packages,
      skipped_packages:      skipped_packages
    ).run
  end
end