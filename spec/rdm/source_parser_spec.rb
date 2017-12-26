require 'spec_helper'

describe Rdm::SourceParser do
  include ExampleProjectHelper

  describe "#parse" do
    subject { Rdm::SourceParser }

    let(:fixtures_path) {
      File.join(File.expand_path("../../", __FILE__), 'fixtures')
    }

    let(:source_path) {
      File.join(fixtures_path, "SampleSource.rb")
    }

    let(:source_content) {
      File.read(source_path)
    }

    before :each do
      @source = subject.read_and_init_source(source_path, stdout: SpecLogger.new)
    end

    it "returns Source object" do
      expect(@source.is_a?(Rdm::Source)).to be_truthy
    end

    it "parses all packages paths" do
      paths = @source.package_paths
      expect(paths.count).to be(2)
      expect(paths).to include("application/web")
      expect(paths).to include("domain/core")
    end
  end


  describe "#parse on real project" do
    subject { Rdm::SourceParser }

    let(:fixtures_path) {
      File.join(File.expand_path("../../../", __FILE__), 'example')
    }

    let(:source_path) {
      File.join(fixtures_path, "Rdm.packages")
    }

    let(:source_content) {
      File.read(source_path)
    }

    before :each do
      @source = subject.read_and_init_source(source_path, stdout: SpecLogger.new)
    end

    it "returns Source object" do
      expect(@source.is_a?(Rdm::Source)).to be_truthy
    end

    it "parses all packages paths" do
      paths = @source.package_paths
      expect(paths.count).to be(4)
      expect(paths).to include("application/web")
      expect(paths).to include("domain/core")
    end
  end
end
