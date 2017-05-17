require "spec_helper"

describe Rdm::Package::Locator do
  subject { described_class }

  let(:example_path) {
    File.join(File.expand_path("../../../", __dir__), "example")
  }

  context "::locate" do
    it "returns package name for existing package path" do
      existing_path = File.join(example_path, 'application/web/package/web/sample_controller.rb')
      
      expect(subject.locate(existing_path)).to eq(File.join(example_path, "application/web"))
    end

    it "returns package name for non existing package path" do
      non_existing_path = File.join(example_path, 'domain/core/invalid/path.rb')

      expect(subject.locate(non_existing_path)).to eq(File.join(example_path, "domain/core"))
    end

    it "raises PackageNotFound error if no package found within source folder" do
      no_package_path = File.join(example_path, 'helpers/url_helper.rb')

      expect{
        subject.locate(no_package_path)
      }.to raise_error(Rdm::Errors::PackageFileDoesNotFound)
    end
  end
end