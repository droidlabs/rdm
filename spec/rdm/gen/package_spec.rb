require "spec_helper"

describe Rdm::Gen::Package do
  include ExampleProjectHelper

  subject { described_class }
  
  before { initialize_example_project }
  after  { reset_example_project }

  context "sample package" do
    it "generates correct files" do
      FileUtils.rm_rf(File.join(example_project_path, '.rdm', 'templates'))

      subject.generate(
        current_path: example_project_path,
        package_name: "some",
        local_path:   "domain/some"
      )

      FileUtils.cd(example_project_path) do
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
      File.open(File.join(example_project_path, '.rdm/templates/package/Package.rb'), 'w') do |f|
        f.write('# modified file for .rdm tempalates directory')
      end

      subject.generate(
        current_path: example_project_path,
        package_name: "some",
        local_path:   "domain/some",
      )

      FileUtils.cd(example_project_path) do
        ensure_content("domain/some/Package.rb", "# modified file for .rdm tempalates directory")
        expect(Dir['domain/some/'].size).to eq(1)
      end
    end

    it "has added new entry to Rdm.packages" do
      subject.generate(
        current_path: example_project_path,
        package_name: "some",
        local_path:   "domain/some",
      )

      FileUtils.cd(example_project_path) do
        ensure_content("Rdm.packages", "package 'domain/some'")
      end
    end
  end

  context "prevents double execution" do
    it "raises on second package generation" do
      subject.generate(
        current_path: example_project_path,
        package_name: "some",
        local_path:   "domain/some",
      )

      expect {
        subject.generate(
          current_path: example_project_path,
          package_name: "some",
          local_path:   "domain/some",
        )
      }.to raise_error(Rdm::Errors::PackageDirExists)
    end

    it "raises on second package generation, if Rdm.packages includes the package (and folder does not exist)" do
      subject.generate(
        current_path: example_project_path,
        package_name: "some",
        local_path:   "domain/some",
      )
      expect {
        subject.generate(
          current_path: example_project_path,
          package_name: "some",
          local_path:   "some",
        )
      }.to raise_error(Rdm::Errors::PackageExists)
    end


    it "add package record to Rdm.packages file" do
      subject.generate(
        package_name: "database",
        current_path: example_project_path,
        local_path:   "infrastructure/database"
      )
      expect(
        Rdm::SourceParser.read_and_init_source(rdm_source_file).packages.keys
      ).to include('database')
    end
  end
end
