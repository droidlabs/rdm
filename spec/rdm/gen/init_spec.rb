require "spec_helper"

describe Rdm::Gen::Init do
  include ExampleProjectHelper

  subject       { described_class }
  let(:stdout)  { SpecLogger.new }

  before { initialize_example_project(skip_rdm_init: true) }
  after  { reset_example_project }

  context "sample project" do
    it "has generated correct files" do
      subject.generate(current_path: example_project_path, stdout: stdout)

      FileUtils.cd(example_project_path) do
        ensure_exists("Rdm.packages")
        ensure_exists("Gemfile")
        ensure_exists("Readme.md")
        ensure_exists("tests/run")
        ensure_exists("bin/console")
        ensure_exists("env_files/test.env")
        ensure_exists("env_files/development.env")
        ensure_exists("env_files/production.env")
      end
    end

    it "has generated package templates" do
      subject.generate(current_path: example_project_path, stdout: stdout)

      FileUtils.cd(example_project_path) do
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
      subject.generate(current_path: example_project_path, stdout: stdout)

      expect {
        subject.generate(current_path: example_project_path, stdout: stdout)
      }.to raise_error(Rdm::Errors::ProjectAlreadyInitialized)
    end
  end
end
