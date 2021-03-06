require "spec_helper"

describe Rdm::CLI::GenPackage do
  include ExampleProjectHelper

  subject      { described_class }
  let(:stdout) { SpecLogger.new }

  before { initialize_example_project }
  after  { reset_example_project }

  context "run" do
    it "generates package" do
      subject.run(
        package_name: "database",
        current_path: example_project_path,
        path:         "infrastructure/database",
        stdout:       stdout
      )

      FileUtils.cd(example_project_path) do
        ensure_exists("infrastructure/database/Package.rb")
        ensure_exists("infrastructure/database/package/database.rb")
        ensure_exists("infrastructure/database/package/database/")
        ensure_exists("infrastructure/database/bin/console")
        ensure_exists("infrastructure/database/spec/spec_helper.rb")
        ensure_exists("infrastructure/database/.rspec")
        ensure_exists("infrastructure/database/.gitignore")
        ensure_content("infrastructure/database/package/database.rb", "module Database\n\nend\n")
      end
    end

    it "has logged useful output" do
      subject.run(
        package_name: "database",
        current_path: example_project_path,
        path:         "infrastructure/database",
        stdout:       stdout
      )

      expect(stdout.output).to include("Generated: infrastructure/database/Package.rb")
    end
  end

  context "run with errors" do
    it "fails when in wrong directory" do
      subject.run(
        package_name: "database",
        current_path: File.dirname(example_project_path),
        path:         "infrastructure/database",
        stdout:       stdout
      )

      expect(stdout.output).to include("Rdm.packages was not found. Run 'rdm init' to create it")
    end

    it "fails when package already created" do
      subject.run(
        package_name: "database",
        current_path: example_project_path,
        path:         "infrastructure/database",
        stdout:       stdout
      )
      
      subject.run(
        package_name: "database",
        current_path: example_project_path,
        path:         "infrastructure/database",
        stdout:       stdout
      )
      expect(stdout.output).to include("Error. Directory infrastructure/database exists. Package was not generated")
    end

    it "fails when package already created" do
      subject.run(
        package_name: "database",
        current_path: example_project_path,
        path:         "infrastructure/database",
        stdout:       stdout
      )

      subject.run(
        package_name: "database",
        current_path: example_project_path,
        path:         "database",
        stdout:       stdout
      )
      expect(stdout.output).to include("Error. Package already exist. Package was not generated")
    end

    it "fails when empty package given" do
      subject.run(
        package_name: "",
        current_path: example_project_path,
        path:         "infrastructure/database",
        stdout:       stdout
      )
      expect(stdout.output).to include("Package name was not specified!")
    end
  end


end
