module Rdm::SpecRunner
  def self.run(path: nil, argv: nil)
    argv ||= ARGV.clone

    input_params = Rdm::SpecRunner::InputParams.new(argv)
    Rdm::SpecRunner::Runner.new(input_params, path: path).run
  end
end