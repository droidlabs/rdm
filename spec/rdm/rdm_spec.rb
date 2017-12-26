require "spec_helper"

describe Rdm do
  let(:example_path) {
    Pathname.new(
      File.join(File.expand_path('../../../', __FILE__), 'example')
    )
  }
  let(:source_file) {
    example_path.join('Rdm.packages').to_s
  }
  let(:package_path) {
    example_path.join("application/web").to_s
  }
  let(:stdout) { SpecLogger.new }

  context "init" do
    it "will initialize RDM based on path to a package.rb file" do
      package = Rdm.init(package_path, stdout: stdout)
      expect(package.name).to eq("web")
    end
  end

  context "settings" do
    it "returns settings" do
      expect(Rdm.settings).to be_a(Rdm::Settings)
    end
  end

  context "config" do
    it "returns config" do
      expect(Rdm.config).to eq(Rdm::ConfigManager)
    end
  end

  context "root=" do
    after { Rdm.root = nil }

    it "sets root" do
      Rdm.root = "/some/path"
      expect(Rdm.root).to eq("/some/path")
    end
  end
end
