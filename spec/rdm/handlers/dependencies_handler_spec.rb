require 'spec_helper'

describe Rdm::Handlers::DependenciesHandler do
  include ExampleProjectHelper

  subject { described_class }

  before { initialize_example_project }
  after  { reset_example_project }

  context ":show_names" do
    it "returns array of dependencies names" do
      expect(
        subject.show_names(
          package_name: 'web',
          project_path: example_project_path
        )
      ).to match(["core", "repository", "web"])
    end
  end

  context ":show_packages" do
    let(:result) {
      subject.show_packages(
        package_name: 'web',
        project_path: example_project_path
      )
    }
    it "returns array with proper size" do
      expect(result.count).to eq(3)
    end

    it "returns array with proper size" do
      expect(result.first).to be_a Rdm::Package
    end
  end

  context ":format_for_draw" do
    context "for simple case" do
      let(:result) {
        subject.draw(
          package_name: 'web',
          project_path: example_project_path
        )
      }
      it "returns hash structure of dependencies" do
        expect(result).to match(
          [
            "web", 
            "└── core",
            "    └── repository"
          ]
        )
      end
    end

    context "for cycle dependencies" do
      before do
        core_package_file = File.join(example_project_path, "domain/core", Rdm::PACKAGE_FILENAME)
        Rdm::Utils::FileUtils.change_file(core_package_file) do |line|
          line.include?('import "repository"') ? '  import "web"' : line
        end
      end

      let(:result) {
        subject.draw(
          package_name: 'web',
          project_path: example_project_path
        )
      }

      it "use one at time" do
        expect(result).to match(
          [
            "web", 
            "└── core", 
            "    └── web", 
            "        └── ..." 
          ]
        )
      end
    end
  end
end