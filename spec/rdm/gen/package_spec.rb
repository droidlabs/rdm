require "spec_helper"

describe Rdm::Gen::Package do
  include SetupHelper

  def generate_package!
    Rdm::Gen::Package.generate_package(
      current_dir: project_dir,
      package_name: "some",
      package_relative_path: "domain/some",
      skip_rspec: false
    )
  end

  def ensure_exists(file)
    expect(File.exists?(file)).to be true
  end

  def ensure_content(file, content)
    expect(File.read(file)).to match(content)
  end

  context "sample package" do
    before :all do
      fresh_project
      generate_package!
    end

    after :all do
      clean_tmp
    end

    it "has generated correct files" do
      FileUtils.cd(project_dir) do
        ensure_exists("domain/some/Package.rb")
        ensure_exists("domain/some/package/some.rb")
        ensure_exists("domain/some/package/some/")
        ensure_exists("domain/some/bin/console")
        ensure_exists("domain/some/spec/spec_helper.rb")
        ensure_exists("domain/some/.rspec")
        ensure_exists("domain/some/.gitignore")
        ensure_content("domain/some/package/some.rb", "module Some\n\nend\n")
      end
    end

    it "has added new entry to Rdm.packages" do
      FileUtils.cd(project_dir) do
        ensure_content("Rdm.packages", "package 'domain/some'")
      end
    end
  end

  context "prevents double execution" do
    after :all do
      clean_tmp
    end

    it "raises on second package generation" do
      fresh_project
      generate_package!
      expect {
        generate_package!
      }.to raise_error(Rdm::Errors::PackageDirExists)
    end

    it "raises on second package generation, if Rdm.packages includes the package (and folder does not exist)" do
      fresh_project
      generate_package!
      FileUtils.rm_rf(File.join(project_dir, "domain/some"))
      expect {
        generate_package!
      }.to raise_error(Rdm::Errors::PackageExists)
    end
  end
end
