require 'spec_helper'

describe Rdm::CLI::DependenciesController do
  include ExampleProjectHelper

  subject { described_class }

  before { initialize_example_project }
  after  { reset_example_project }

  let(:stdout) { SpecLogger.new }

  context ":run" do
    it "returns array of dependencies names" do
      subject.run(
        package_name: 'web',
        project_path: example_project_path,
        stdout:       stdout
      )
      
      expect(stdout.output).to include(
        [
          "web", 
          "└── core",
          "    └── repository"
        ]
      )
    end

    it "returns no dependencies message" do
      subject.run(
        package_name: 'repository',
        project_path: example_project_path,
        stdout:       stdout
      )
      
      expect(stdout.output).to include("Package `repository` has no dependencies")
    end

    it "show error message if package_name not specified" do
      subject.run(
        package_name: '',
        project_path: example_project_path,
        stdout:       stdout
      )

      expect(stdout.output).to include("Type package name, ex: rdm gen.deps repository")
    end
  end
end