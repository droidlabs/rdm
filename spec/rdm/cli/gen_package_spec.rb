require "spec_helper"

describe Rdm::CLI::GenPackage do
  include SetupHelper

  before :all do
    Rdm::Gen::Package.disable_logger!
  end

  def generate_project!
    Rdm::Gen::Init.generate(
      current_dir: empty_project_dir
    )
  end

  def ensure_exists(file)
    expect(File.exists?(file)).to be true
  end

  def ensure_content(file, content)
    expect(File.read(file)).to match(content)
  end

  context "run" do
    before :all do
      fresh_project
    end

    after :all do
      clean_tmp
    end

    it "generates package" do
      opts = {
        package_name: "database",
        current_dir:  project_dir,
        path:         "infrastructure/database" ,
        skip_tests:   false
      }
      Rdm::CLI::GenPackage.run(opts)

      FileUtils.cd(project_dir) do
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
  end

  context "run with errors" do
    before :all do
      clean_tmp
    end

    after :all do
      clean_tmp
    end

    it "fails when in wrong directory" do
      opts = {
        package_name: "database",
        current_dir:  project_dir,
        path:         "infrastructure/database" ,
        skip_tests:   false
      }

      expect{
        Rdm::CLI::GenPackage.run(opts)
      }.to output(/Rdm.packages\ not\ found/).to_stdout
    end

    it "fails when package already created" do
      fresh_project
      opts = {
        package_name: "database",
        current_dir: project_dir,
        path: "infrastructure/database" ,
        skip_tests: false
      }
      Rdm::CLI::GenPackage.run(opts)

      expect{
        Rdm::CLI::GenPackage.run(opts)
      }.to output(Regexp.new("Error. Directory infrastructure/database exists. Package was not generated")).to_stdout
      clean_tmp
    end

    it "fails when package already created" do
      fresh_project
      opts = {
        package_name: "database",
        current_dir: project_dir,
        path: "infrastructure/database" ,
        skip_tests: false
      }
      Rdm::CLI::GenPackage.run(opts)

      FileUtils.rm_rf(File.join(project_dir, "infrastructure/database"))

      expect{
        Rdm::CLI::GenPackage.run(opts)
      }.to output(Regexp.new("Error. Package already exist. Package was not generated")).to_stdout
      clean_tmp
    end

    it "fails when empty package given" do
      fresh_project
      opts = {
        package_name: "",
        current_dir: project_dir,
        path: "infrastructure/database" ,
        skip_tests: false
      }
      begin
        expect{
          Rdm::CLI::GenPackage.run(opts)
        }.to output(Regexp.new("Package name was not specified!")).to_stdout
      rescue SystemExit
        clean_tmp
      end
    end
  end


end
