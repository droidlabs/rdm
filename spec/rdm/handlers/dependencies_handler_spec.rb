require 'spec_helper'

describe Rdm::Handlers::DependenciesHandler do
  include ExampleProjectHelper

  subject { described_class }

  before { @project_path = initialize_example_project }
  after  { reset_example_project(path: @project_path) }

  context ":show_names" do
    it "returns array of dependencies names" do
      expect(
        subject.show_names(
          package_name: 'web',
          project_path: @project_path
        )
      ).to match(["core", "web"])
    end
  end

  context ":show_packages" do
    let(:result) {
      subject.show_packages(
        package_name: 'web',
        project_path: @project_path
      )
    }
    it "returns array with proper size" do
      expect(result.count).to eq(2)
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
          project_path: @project_path
        )
      }
      it "returns hash structure of dependencies" do
        expect(result).to match(
          [
            "web", 
            "└── core"
          ]
        )
      end
    end

    context "for cycle dependencies" do
      before do
        File.open(File.join(@project_path, "domain/core", Rdm::PACKAGE_FILENAME), 'w') do |f|
          f.write <<~EOF
            package do
              name "core"
              version "1.0"
            end

            dependency do
              import "web"
              import "api"
            end
          EOF
        end
      end
      let(:result) {
        subject.draw(
          package_name: 'web',
          project_path: @project_path
        )
      }

      it "use one at time" do
        expect(result).to match(
          [
            "web", 
            "└── core", 
            "    ├── api", 
            "    |   └── web", 
            "    |       └── ...", 
            "    └── web", 
            "        └── ..."
          ]
        )
      end
    end
  end
end