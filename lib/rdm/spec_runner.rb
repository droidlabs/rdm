module Rdm::SpecRunner
  def self.run(
    path:                  nil, 
    package:               nil, 
    spec_matcher:          nil, 
    show_missing_packages: true, 
    skip_ignored_packages: false
  )
    Rdm::SpecRunner::Runner.new(
      path:                  path, 
      package:               package, 
      spec_matcher:          spec_matcher, 
      show_missing_packages: show_missing_packages,
      skip_ignored_packages: skip_ignored_packages
    ).run
  end
end