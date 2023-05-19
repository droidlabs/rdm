require 'spec_helper'

describe Rdm::SpecRunner do
  include ExampleProjectHelper
  
  before { initialize_example_project }
  after  { reset_example_project }

  subject      { described_class }
  let(:stdout) { SpecLogger.new }

  context "for specified spec_matcher" do
    context "if no files match spec_matcher" do
      it 'output warning message' do
        subject.run(
          path:         example_project_path, 
          package:      'core',
          spec_matcher: 'not_existing_file.rb',
          stdout:       stdout
        )

        expect(stdout.output).to include("No specs were found for 'not_existing_file.rb'")
      end
    end

    context "if multiple files match spec_matcher" do
      it 'output list of matches' do
        subject.run(
          path:         example_project_path, 
          package:      'core',
          spec_matcher: 'spec.rb',
          stdout:       stdout,
          stdin:        SpecLogger.new(stdin: "exit\n")
        )

        expect(stdout.output).to match(["Following specs match your input:", "1. spec/core/one_more_spec.rb\n2. spec/core/sample_service_spec.rb", "Enter space-separated file numbers, ex: '1 2': "])
      end
    end
  end
end