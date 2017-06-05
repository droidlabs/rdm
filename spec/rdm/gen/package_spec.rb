require "spec_helper"

describe Rdm::Gen::Package do
  include ExampleProjectHelper

  subject { described_class }
  
  before do
    @project_path = initialize_example_project(package_template: true)
  end

  after do
    reset_example_project(path: @project_path)
  end

  context "sample package" do
    it "has generated correct files" do
      FileUtils.rm_rf(File.join(@project_path, '.rdm'))

      subject.generate(
        current_path: @project_path,
        package_name: "some",
        local_path:   "domain/some",
      )

      FileUtils.cd(@project_path) do
        ensure_exists("domain/some/Package.rb")
        ensure_exists("domain/some/package/some.rb")
        ensure_exists("domain/some/package/some/")
        ensure_exists("domain/some/bin/console")
        ensure_exists("domain/some/spec/spec_helper.rb")
        ensure_exists("domain/some/.rspec")
        ensure_exists("domain/some/.gitignore")
      end
    end

    it "takes template from '.rdm' directory primarily" do
      File.open(File.join(@project_path, '.rdm/templates/package/Package.rb'), 'w') do |f|
        f.write('# modified file for .rdm tempalates directory')
      end

      subject.generate(
        current_path: @project_path,
        package_name: "some",
        local_path:   "domain/some",
      )

      FileUtils.cd(@project_path) do
        ensure_content("domain/some/Package.rb", "# modified file for .rdm tempalates directory")
        expect(Dir['domain/some/'].size).to eq(1)
      end
    end

    it "has added new entry to Rdm.packages" do
      subject.generate(
        current_path: @project_path,
        package_name: "some",
        local_path:   "domain/some",
      )

      FileUtils.cd(@project_path) do
        ensure_content("Rdm.packages", "package 'domain/some'")
      end
    end
  end

  context "prevents double execution" do
    it "raises on second package generation" do
      subject.generate(
        current_path: @project_path,
        package_name: "some",
        local_path:   "domain/some",
      )

      expect {
        subject.generate(
          current_path: @project_path,
          package_name: "some",
          local_path:   "domain/some",
        )
      }.to raise_error(Rdm::Errors::PackageDirExists)
    end

    it "raises on second package generation, if Rdm.packages includes the package (and folder does not exist)" do
      subject.generate(
        current_path: @project_path,
        package_name: "some",
        local_path:   "domain/some",
      )
      expect {
        subject.generate(
          current_path: @project_path,
          package_name: "some",
          local_path:   "some",
        )
      }.to raise_error(Rdm::Errors::PackageExists)
    end
  end
end
