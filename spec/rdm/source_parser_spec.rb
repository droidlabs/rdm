require 'spec_helper'

describe Rdm::SourceParser do
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
      @source = subject.read_and_init_source(source_path)
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

    it "parses all config names" do
      names = @source.config_names
      expect(names.count).to be(1)
      expect(names).to include("database")
    end
  end
end
