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

        expect(stdout.output).to include("No files were found for 'not_existing_file.rb'")
      end
    end

    context "if single file match spec_matcher" do
      # it 'runs spec file' do
      #   subject.run(
      #     path:         example_project_path, 
      #     package:      'core',
      #     spec_matcher: 'spec/core/sample_service_spec.rb',
      #     stdout:       stdout
      #   )

      #   expect(stdout.output).to include('No files specified by spec_matcher were found')
      # end
    end

    context "if multiple files match spec_matcher" do
      it 'output list of matches' do
        subject.run(
          path:         example_project_path, 
          package:      'core',
          spec_matcher: 'spec.rb',
          stdout:       stdout
        )

        expect(stdout.output).to include("Following files were found by specified spec_matcher:\n1. package/core/sample_service.rb\n2. spec/core/one_more_spec.rb\n3. spec/core/sample_service_spec.rb")
      end
    end
  end
end