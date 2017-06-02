require "spec_helper"

describe Rdm::Gen::Init do
  include SetupHelper

  def generate_project!
    Rdm::Gen::Init.generate(
      current_dir: empty_project_dir
    )
  end

  context "sample project" do
    before :all do
      Rdm::Gen::Init.disable_logger!
      fresh_empty_project
      generate_project!
    end

    after :all do
      clean_tmp
    end

    it "has generated correct files" do
      FileUtils.cd(empty_project_dir) do
        ensure_exists("Rdm.packages")
        ensure_exists("Gemfile")
        ensure_exists("Readme.md")
        ensure_exists("tests/run")
      end
    end

    it "has generated package templates" do
      FileUtils.cd(empty_project_dir) do
        ensure_exists(".rdm/package_templates/package.rb.erb")
        ensure_exists(".rdm/package_templates/main_module_file.rb.erb")
        ensure_exists(".rdm/package_templates/.rspec")
        ensure_exists(".rdm/package_templates/.gitignore")
        ensure_exists(".rdm/package_templates/spec/spec_helper.rb")
        ensure_exists(".rdm/package_templates/bin/console_irb")
      end
    end

    it "has logged useful output" do
      Rdm::Gen::Init.enable_logger!
      expect {
        fresh_empty_project
        generate_project!
      }.to output(/Generated: Rdm.packages/).to_stdout
      Rdm::Gen::Init.disable_logger!
    end
  end

  context "prevents double execution" do
    after :all do
      clean_tmp
    end

    it "raises on second project generation" do
      fresh_empty_project
      generate_project!
      expect {
        generate_project!
      }.to raise_error(Rdm::Errors::ProjectAlreadyInitialized)
    end
  end
end
