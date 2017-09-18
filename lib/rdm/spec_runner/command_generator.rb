class Rdm::SpecRunner::CommandGenerator
  attr_accessor :package_name, :package_path, :spec_matcher
  def initialize(package_name:, package_path:, spec_matcher:, show_output: true)
    @package_name = package_name
    @package_path = package_path
    @spec_matcher = spec_matcher
    @output       = show_output ? '$stdout' : 'File::NULL'
  end

  def spec_count
    Dir[File.join(package_path, 'spec/**/*_spec.rb')].size
  end

  def command
    "print_message(
        '**** Package: #{package_name}  *****') \\
          && system('cd #{package_path} \\
          && bundle exec rspec --color --tty #{spec_matcher}', out: #{@output.to_s}, err: :out)"
  end

  def generate
    Rdm::SpecRunner::CommandParams.new.tap do |cp|
      cp.package_name = package_name
      cp.package_path = package_path
      cp.command      = command
      cp.spec_count   = spec_count
    end
  end
end