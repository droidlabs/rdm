require "spec_helper"
require "fileutils"

describe Rdm::Git::DiffManager do
  subject { described_class }

  describe "::get_diffs" do
    before :each do
      @git_example_path = File.join("/tmp", 'git_example')
      Dir.mkdir(@git_example_path)

      File.open(File.join(@git_example_path, 'file_to_modify.rb'), 'w') { |f| f.write('I will be modified') }
      File.open(File.join(@git_example_path, 'file_to_delete.rb'), 'w') { |f| f.write('I will be deleted') }
    end

    context "contains all modified files if present" do
      before do
        %x( cd #{@git_example_path} && git init && git add . && git commit -am "Initial commit" )

        @new_filename = File.join(@git_example_path, 'new_file.rb')
        File.open(@new_filename, 'w') { |f| f.write('I am new file') }

        @modified_filename = File.join(@git_example_path, 'file_to_modify.rb')
        File.open(@modified_filename, 'a') { |f| f.write('I am modified now!') }

        @deleted_filename = File.join(@git_example_path, 'file_to_delete.rb')
        FileUtils.rm(@deleted_filename)
      end

      it "shows new files" do
        expect(subject.run(@git_example_path)).to include(@new_filename)
      end

      it "shows edited files" do
        expect(subject.run(@git_example_path)).to include(@modified_filename)
      end

      it "shows deleted files" do
        expect(subject.run(@git_example_path)).to include(@deleted_filename)
      end

      it "returns array" do
        expect(subject.run(@git_example_path)).to be_a(Array)
        expect(subject.run(@git_example_path).size).to eq(3)
      end
    end

    context "does't contain any modified files if not present" do
      before do
        %x( cd #{@git_example_path} && git init && git add . && git commit -am "Initial commit" )
      end

      it "returns empty array of modified files" do
        expect(subject.run(@git_example_path)).to eq([])
      end
    end

    context "if git repository was not initialized" do
      it "raises Rdm::Errors::GitRepositoryNotInitialized" do
        expect{
          subject.run(@git_example_path)
        }.to raise_error(Rdm::Errors::GitRepositoryNotInitialized)
      end
    end

    after :each do
      FileUtils.rm_r(@git_example_path)
    end
  end
end