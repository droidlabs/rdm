require "spec_helper"

describe Rdm::Gen::Init do
  include ExampleProjectHelper

  subject { described_class }

  before do
    @project_path = initialize_example_project

    FileUtils.rm_rf [
      File.join(@project_path, 'Rdm.packages'),
      File.join(@project_path, 'Gemfile'),
      File.join(@project_path, 'Readme.md'),
      File.join(@project_path, 'tests/run'),
      File.join(@project_path, '.rdm/templates/package')
    ]
  end

  after do
    reset_example_project(path: @project_path)
  end

  context "sample project" do
    it "has generated correct files" do
      subject.generate(current_path: @project_path)

      FileUtils.cd(@project_path) do
        ensure_exists("Rdm.packages")
        ensure_exists("Gemfile")
        ensure_exists("Readme.md")
        ensure_exists("tests/run")
      end
    end

    it "has generated package templates" do
      subject.generate(current_path: @project_path)

      FileUtils.cd(@project_path) do
        ensure_exists(".rdm/templates/package/Package.rb")
        ensure_exists(".rdm/templates/package/<%=package_subdir_name%>/<%=package_name%>.rb")
        ensure_exists(".rdm/templates/package/.rspec")
        ensure_exists(".rdm/templates/package/.gitignore")
        ensure_exists(".rdm/templates/package/spec/spec_helper.rb")
        ensure_exists(".rdm/templates/package/bin/console")
      end
    end
  end

  context "prevents double execution" do
    it "raises on second project generation" do
      subject.generate(current_path: @project_path)

      expect {
        subject.generate(current_path: @project_path)
      }.to raise_error(Rdm::Errors::ProjectAlreadyInitialized)
    end
  end
end
