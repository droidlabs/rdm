require 'spec_helper'

describe Rdm::SourceParser do
  describe "#parse" do
    subject { Rdm::SourceParser }

    let(:source_content) {
      %Q{package "application/web"\r\npackage "domain/core"}
    }

    it "returns Source object" do
      source = subject.parse(source_content)
      expect(source.is_a?(Rdm::Source)).to be_truthy
    end

    it "returns all packages paths" do
      paths = subject.parse(source_content).package_paths
      expect(paths.count).to be(2)
      expect(paths).to include("application/web")
      expect(paths).to include("domain/core")
    end
  end
end