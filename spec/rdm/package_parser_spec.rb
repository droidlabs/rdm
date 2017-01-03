require 'spec_helper'

describe Rdm::PackageParser do
  describe "#parse_file" do
    let(:fixtures_path) {
      File.join(File.expand_path("../../", __FILE__), 'fixtures')
    }

    let(:package_path) {
      File.join(fixtures_path, "sample_prj/infrastructure/web/Package.rb")
    }
    let(:package) { Rdm::PackageParser.parse_file(package_path) }

    it "parses package meta information" do
      expect(package.name).to eq("web")
      expect(package.version).to eq("1.0")
    end

    it "parses local dependecies" do
      expect(package.local_dependencies).to include("core")
      expect(package.local_dependencies).to_not include("test_factory")

      expect(package.local_dependencies(:test)).to include("core")
      expect(package.local_dependencies(:test)).to include("test_factory")
    end

    it "parses external dependecies" do
      expect(package.external_dependencies).to include("active_support")
      expect(package.external_dependencies).to_not include("rspec")

      expect(package.external_dependencies(:test)).to include("active_support")
      expect(package.external_dependencies(:test)).to include("rspec")
    end

    it "parses file dependecies" do
      expect(package.file_dependencies).to include("lib/web.rb")
      expect(package.file_dependencies).to_not include("lib/spec.rb")

      expect(package.file_dependencies(:test)).to include("lib/web.rb")
      expect(package.file_dependencies(:test)).to include("lib/spec.rb")
    end
  end
end
