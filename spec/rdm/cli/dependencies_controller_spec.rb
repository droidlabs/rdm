require 'spec_helper'

describe Rdm::CLI::DependenciesController do
  include ExampleProjectHelper

  subject { described_class }

  before { @project_path = initialize_example_project }
  after  { reset_example_project(path: @project_path) }
  let(:stdout) { SpecLogger.new }

  context ":run" do
    it "returns array of dependencies names" do
      subject.run(
        package_name: 'web',
        project_path: @project_path,
        stdout:       stdout
      )
      
      expect(stdout.output).to include("Package `web` dependent on this packages:")
      expect(stdout.output).to include(["  1. core"])
    end

    it "returns no dependencies message" do
      subject.run(
        package_name: 'core',
        project_path: @project_path,
        stdout:       stdout
      )
      
      expect(stdout.output).to include("Package `core` has no dependencies")
    end
  end
end