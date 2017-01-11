require "spec_helper"

describe Rdm::CLI::Init do
  include SetupHelper

  before :all do
    Rdm::Gen::Init.disable_logger!
  end

  def ensure_exists(file)
    expect(File.exists?(file)).to be true
  end

  def ensure_content(file, content)
    expect(File.read(file)).to match(content)
  end

  context "run" do
    before :all do
      fresh_empty_project
    end

    after :all do
      clean_tmp
    end

    it "generates package" do
      opts = {
        current_dir: empty_project_dir,
        console: "irb",
        test: "rspec"
      }
      Rdm::CLI::Init.run(opts)

      FileUtils.cd(empty_project_dir) do
        ensure_exists("Rdm.packages")
        ensure_exists("Gemfile")
        ensure_exists("Readme.md")
        ensure_exists("tests/run")
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
        current_dir: empty_project_dir + "/not-there",
        console: "irb",
        test: "rspec"
      }

      expect{
        Rdm::CLI::Init.run(opts)
      }.to output(Regexp.new("Please run on empty directory")).to_stdout
    end

    it "fails when project already initialized" do
      fresh_empty_project
      opts = {
        current_dir: empty_project_dir,
        console: "irb",
        test: "rspec"
      }
      Rdm::CLI::Init.run(opts)

      expect{
        Rdm::CLI::Init.run(opts)
      }.to output(Regexp.new("Error. Project was already initialized")).to_stdout
      clean_tmp
    end

    it "fails with wrong current_dir and exits" do
      opts = {
        current_dir: "",
        console: "irb",
        test: "rspec"
      }

      a = 0
      begin
        a = 1
        Rdm::CLI::Init.run(opts)
        a = 2
      rescue SystemExit
        expect(a).to eq(1)
      end
    end
  end
end
