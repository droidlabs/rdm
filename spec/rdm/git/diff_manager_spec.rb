require "spec_helper"

describe Rdm::Git::DiffManager do
  subject { described_class }

  describe "::get_diffs" do
    before :each do
      @git_example_path = File.join("/tmp", 'git_example')
      FileUtils.mkdir_p(File.join(@git_example_path, 'files'))

      File.open(File.join(@git_example_path, 'files/file_to_modify.rb'), 'w') { |f| f.write('I will be modified') }
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

        @nested_file = File.join(@git_example_path, 'files/nested_file.rb')
        File.open(@nested_file, 'w') { |f| f.write("I'm nested file!") }

        %x( cd #{@git_example_path} && git init && git add . )
      end

      it "shows new files" do
        expect(subject.run(path: @git_example_path, git_point: 'HEAD')).to include(@new_filename)
      end

      it "shows edited files" do
        expect(subject.run(path: @git_example_path, git_point: 'HEAD')).to include(@modified_filename)
      end

      it "shows deleted files" do
        expect(subject.run(path: @git_example_path, git_point: 'HEAD')).to include(@deleted_filename)
      end

      it "shows files with folder structure" do
        expect(subject.run(path: @git_example_path, git_point: 'HEAD')).to include(@nested_file)
      end

      it "returns array" do
        expect(subject.run(path: @git_example_path, git_point: 'HEAD')).to be_a(Array)
        expect(subject.run(path: @git_example_path, git_point: 'HEAD').size).to eq(4)
      end
    end

    context "does't contain any modified files if not present" do
      before do
        %x( cd #{@git_example_path} && git init && git add . && git commit -am "Initial commit" )
      end

      it "returns empty array of modified files" do
        expect(subject.run(path: @git_example_path, git_point: 'HEAD')).to eq([])
      end
    end

    context "if git repository was not initialized" do
      it "raises Rdm::Errors::GitRepositoryNotInitialized" do
        expect{
          subject.run(path: @git_example_path, git_point: 'HEAD')
        }.to raise_error(Rdm::Errors::GitRepositoryNotInitialized)
      end
    end

    after :each do
      FileUtils.rm_r(@git_example_path)
    end
  end
end