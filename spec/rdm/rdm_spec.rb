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

  context "init" do
    it "will initialize RDM based on path to a package.rb file" do
      package = Rdm.init(package_path)
      expect(package.name).to eq("web")
    end
  end
end
