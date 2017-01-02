require 'spec_helper'

describe Rdm::SourceLocator do
  describe "::locate" do
    subject { Rdm::SourceParser }

    let(:example_path) {
      Pathname.new(
        File.join(File.expand_path('../../../', __FILE__), 'example')
      )
    }
    let(:source_file) {
      example_path.join('Rdm.packages').to_s
    }

    def locate(path)
      Rdm::SourceLocator.locate(path)
    end

    it "works within valid root folder" do
      expect(locate(example_path)).to eq(source_file)
    end

    it "works in any (deep) subfolder of valid root folder" do
      path1 = example_path.join('domain/core')
      path2 = example_path.join('infrastructure/repository/package/repository')
      expect(locate(path1)).to eq(source_file)
      expect(locate(path2)).to eq(source_file)
    end

    it "even works for non-exiting subfolders of valid root folder" do
      path1 = example_path.join('domain/invalid')
      path2 = example_path.join('just/some/random/folders/here')
      expect(locate(path1)).to eq(source_file)
      expect(locate(path2)).to eq(source_file)
    end

    it "raises when source file could not be found in any folder for the whole folder hierarchy" do
      path1 = "/tmp/not/valid"
      expect {
        locate(path1)
      }.to raise_error(Rdm::Errors::SourceFileDoesNotExist, path1)
    end
  end
end
