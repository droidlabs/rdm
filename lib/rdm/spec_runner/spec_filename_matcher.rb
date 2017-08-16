class Rdm::SpecRunner::SpecFilenameMatcher
  class << self
    def find_matches(package_path:, spec_matcher:)
      Rdm::SpecRunner::SpecFilenameMatcher.new(package_path, spec_matcher).find_matches
    end
  end

  def initialize(package_path, spec_matcher)
    @package_path = package_path
    @spec_matcher = spec_matcher
  end

  def find_matches
    expected_filename = File.join(@package_path, @spec_matcher)

    if File.exists?(expected_filename)
      return Rdm::Utils::FileUtils.relative_path(path: expected_filename, from: @package_path).split
    end

    Dir.glob(File.join(@package_path, '**/*_spec.rb'))
      .select { |fn| File.file?(fn) }
      .map {|file| Rdm::Utils::FileUtils.relative_path(path: file, from: @package_path) }
      .grep(/#{@spec_matcher.split('').join('.*')}/)
  end
  
end