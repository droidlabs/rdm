require "spec_helper"

describe Rdm::Handlers::DiffPackageHandler do
  include ExampleProjectHelper
  include GitCommandsHelper

  subject { described_class }

  context "::handle" do    
    before { initialize_example_project }
    after  { reset_example_project }

    context "when git changes present" do
      context "for package without dependencies" do
        before do
          git_initialize_repository(example_project_path)
          git_commit_changes(example_project_path)

          File.open(File.join(example_project_path, 'server/package/new_server.rb'), 'w') { |f| f.write '' }

          git_index_changes(example_project_path)
        end

        it "returns only modified packages" do
          expect(subject.handle(path: example_project_path, revision: 'HEAD')).to match(["server"])
        end
      end

      context "for package with dependencies" do
        before do
          git_initialize_repository(example_project_path)
          git_commit_changes(example_project_path)

          File.open(File.join(example_project_path, 'domain/core/package/core/new_service.rb'), 'w') do |f| 
            f.write <<~EOF
              class Core::NewService
              end
            EOF
          end
        end

        it "returns array of modified and dependend packages for indexed changes" do
          git_index_changes(example_project_path)
          
          expect(subject.handle(path: example_project_path, revision: 'HEAD')).to match(["core", "server", "web"].sort)
        end
      end

      context "for file without package" do
        before do
          git_initialize_repository(example_project_path)
          git_commit_changes(example_project_path)

          File.open(File.join(example_project_path, 'domain/missing_package_class.rb'), 'w') do |f|
            f.write <<~EOF
              class MissingPackageClass
              end
            EOF
          end
        end

        it "returns empty array" do
          git_index_changes(example_project_path)

          expect(subject.handle(path: example_project_path, revision: 'HEAD')).to eq([])
        end
      end
    end

    context "when git repository is not initialized" do
      it "raises Rdm::Errors::GitRepositoryNotInitialized error" do
        expect{
          subject.handle(path: example_project_path, revision: 'HEAD')
        }.to raise_error(Rdm::Errors::GitRepositoryNotInitialized)
      end
    end
  end
end