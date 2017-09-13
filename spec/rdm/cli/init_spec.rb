require "spec_helper"

describe Rdm::CLI::Init do
  include ExampleProjectHelper

  subject       { described_class }
  let(:stdout)  { SpecLogger.new }


  before { initialize_example_project(skip_rdm_init: true) }
  after  { reset_example_project }

  context "run" do
    it "generates package" do
      subject.run(
        current_path: example_project_path,
        console:     "irb",
        test:        "rspec",
        stdout:      stdout
      )

      FileUtils.cd(example_project_path) do
        ensure_exists("Rdm.packages")
        ensure_exists("Gemfile")
        ensure_exists("Readme.md")
      end
    end

    it "output list of generated files" do
      subject.run(
        current_path: example_project_path,
        console:     "irb",
        test:        "rspec",
        stdout:      stdout
      )
      expect(stdout.output).to include('Generated: Rdm.packages')
    end
  end

  context "run with errors" do
    it "fails when in wrong directory" do
      subject.run(
        current_path: example_project_path + "/not-there",
        console:      "irb",
        test:         "rspec",
        stdout:       stdout
      )
      expect(stdout.output).to include("/tmp/example/not-there doesn't exist. Initialize new rdm project with existing directory")
    end

    it "fails when project already initialized" do
      subject.run(        
        current_path: example_project_path,
        console:     "irb",
        test:        "rspec",
        stdout:      stdout
      )

      subject.run(
        current_path: example_project_path,
        console:     "irb",
        test:        "rspec",
        stdout:      stdout
      )
      expect(stdout.output).to include("Error. Project was already initialized")
    end

    it "fails with wrong current_path and exits" do
      subject.run(
        current_path: "",
        console:     "irb",
        test:        "rspec",
        stdout:      stdout
      )
      expect(stdout.output).to include("Error. Project folder not specified. Type path to rdm project, ex: 'rdm init .'")
    end
  end
end
