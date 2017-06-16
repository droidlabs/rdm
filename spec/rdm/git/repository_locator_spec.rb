require "spec_helper"

describe Rdm::Git::RepositoryLocator do
  include GitCommandsHelper
  include ExampleProjectHelper

  subject { described_class }

  context "::locate" do
    before { initialize_example_project }
    after  { reset_example_project }

    it "returns root of git repository if initialized for existing path" do
      %x( cd #{example_project_path} && git init )

      expect(subject.locate(File.join(example_project_path, "application"))).to eq(example_project_path)
    end

    it "returns root of git repository if initialized for non existing path" do
      %x( cd #{example_project_path} && git init )

      expect(subject.locate(File.join(example_project_path, "non_existing_path"))).to eq(example_project_path)
    end

    it "raises error Rdm::Errors::GitRepositoryNotInitialized if not initialized" do
      expect{
        subject.locate(File.join(example_project_path, "application"))
      }
    end
  end
end