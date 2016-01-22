require 'spec_helper'

describe Rdm::PackageParser do
  describe "#parse" do
    subject { Rdm::PackageParser }

    let(:package_content) {
      %Q{
        package do
          name "web"
          version "1.0"
        end

        dependency do
          import "core"
          require "active_support"
          require_file "lib/web.rb"
        end

        dependency :test do
          import "test_factory"
          require "rspec"
          require_file "lib/spec.rb"
        end
      }
    }

    let(:package) { subject.parse(package_content) }

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