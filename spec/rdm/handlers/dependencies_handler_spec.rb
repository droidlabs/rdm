require 'spec_helper'

describe Rdm::Handlers::DependenciesHandler do
  include ExampleProjectHelper

  subject { described_class }

  before { @project_path = initialize_example_project }
  after  { reset_example_project(path: @project_path) }

  context ":show_names" do
    it "returns array of dependencies names" do
      expect(
        subject.show_names(
          package_name: 'web',
          project_path: @project_path
        )
      ).to match(["core", "web"])
    end
  end

  context ":show_packages" do
    let(:result) {
      subject.show_packages(
        package_name: 'web',
        project_path: @project_path
      )
    }
    it "returns array with proper size" do
      expect(result.count).to eq(2)
    end

    it "returns array with proper size" do
      expect(result.first).to be_a Rdm::Package
    end
  end
end