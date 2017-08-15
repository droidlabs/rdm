require 'spec_helper'

describe Rdm::SpecRunner::SpecFilenameMatcher do
  include ExampleProjectHelper
  
  before { initialize_example_project }
  after  { reset_example_project }

  subject              { described_class }
  let(:existing_file)  { 'package/core.rb' }
  let(:short_filename) { 'pkg.rb' }
  let(:package_path)   { File.join(example_project_path, 'domain/core') }

  context 'file_path exists' do
    it 'returns array with file_path matches' do
      expect(
        subject.find_matches(package_path: package_path, spec_matcher: existing_file)
      ).to eq([existing_file])
    end
  end

  context 'file_path does not exist' do
    it 'returns array of relative to package matches' do
      expect(
        subject.find_matches(package_path: package_path, spec_matcher: short_filename)
      ).to match(["package/core/sample_service.rb", "package/core.rb"])
    end
  end
end