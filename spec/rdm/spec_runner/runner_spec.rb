require 'spec_helper'

describe Rdm::SpecRunner::Runner do
  include ExampleProjectHelper

  let(:stdout) { SpecLogger.new }

  before  { initialize_example_project }
  after   { reset_example_project }

  describe "::run" do
    it 'run all test without errors' do  
      expect{
        described_class.new(
          path:                  example_project_path, 
          package:               nil, 
          spec_matcher:          nil, 
          show_missing_packages: false,
          skip_ignored_packages: false,
          stdout:                stdout,
          show_output:           false
        ).run
      }.not_to raise_error 
    end

    it 'run tests for specified package without errors' do  
      expect{
        described_class.new(
          path:                  example_project_path, 
          package:               'repository', 
          spec_matcher:          nil, 
          show_missing_packages: false,
          skip_ignored_packages: false,
          stdout:                stdout,
          show_output:           false
        ).run
      }.not_to raise_error 
    end

    it 'run tests for specified package and spec_matcher without errors' do  
      expect{
        described_class.new(
          path:                  example_project_path, 
          package:               'repository', 
          spec_matcher:          'example_spec.rb', 
          show_missing_packages: false,
          skip_ignored_packages: false,
          stdout:                stdout,
          show_output:           false
        ).run
      }.not_to raise_error 
    end

    it 'execute spec content' do
      described_class.new(
        path:                  example_project_path, 
        package:               'repository', 
        spec_matcher:          'example_spec.rb', 
        show_missing_packages: false,
        skip_ignored_packages: false,
        stdout:                stdout,
        show_output:           false
      ).run

      expect(
        File.read(File.join(example_project_path, 'infrastructure/repository/fixture.txt'))
      ).to eq('Repository spec working here!')
    end
  end
end