require "spec_helper"

describe Rdm::Gen::Init do
  include SetupHelper

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
