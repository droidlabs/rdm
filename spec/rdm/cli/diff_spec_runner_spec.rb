require 'spec_helper'

describe Rdm::CLI::DiffSpecRunner do
  include ExampleProjectHelper
  include GitCommandsHelper

  subject      { described_class }
  let(:stdout) { SpecLogger.new }

  before { initialize_example_project }
  after do 
    reset_example_project
    stdout.clean
  end

  describe '::run' do
    context 'for not initialized git repository' do
      it 'puts message to initialize git repository' do
        subject.run(path: example_project_path, stdout: stdout)

        expect(stdout.output).to include("Git repository is not initialized. Use `git init .`")
      end
    end

    context 'for initialized git repository' do
      context 'if no files were changed' do
        it 'puts message about no changed packages were found' do
          git_initialize_repository(example_project_path)
          git_commit_changes(example_project_path)

          subject.run(path: example_project_path, stdout: stdout)

          expect(stdout.output).to include("No modified packages were found. Type `git add .` to index all changes...")
        end
      end

      context 'if any files were changed' do
        it 'puts the list of changed packages' do
          git_initialize_repository(example_project_path)
          git_commit_changes(example_project_path)

          File.open(
            File.join(example_project_path, 'server/package/server.rb'), 'w+'
          ) {|f| f.write '# some comment message'}

          git_index_changes(example_project_path)

          subject.run(path: example_project_path, stdout: stdout, show_output: false)

          expect(stdout.output).to include("Tests for the following packages will run:\n  - server\n\n")
        end
      end
    end
  end
end