require "spec_helper"

describe Rdm::Handlers::DiffPackageHandler do
  include ExampleProjectHelper
  include GitCommandsHelper

  subject { described_class }

  context "::handle" do    
    before do
      @example_path = initialize_example_project
    end
    
    after do
      reset_example_project(path: @example_path)
    end

    context "when git changes present" do
      context "for package without dependencies" do
        before do
          git_initialize_repository(@example_path)
          git_commit_changes(@example_path)

          File.open(File.join(@example_path, 'subsystems/api/package/api/new_controller.rb'), 'w') do |f| 
            f.write <<~EOF
              class Web::NewController
              end
            EOF
          end

          git_index_changes(@example_path)
        end

        it "returns only modified packages" do
          expect(subject.handle(path: @example_path, revision: 'HEAD')).to eq(["api"])
        end
      end

      context "for package with dependencies" do
        before do
          git_initialize_repository(@example_path)
          git_commit_changes(@example_path)

          File.open(File.join(@example_path, 'domain/core/package/core/new_service.rb'), 'w') do |f| 
            f.write <<~EOF
              class Core::NewService
              end
            EOF
          end
        end

        it "returns array of modified and dependend packages for indexed changes" do
          git_index_changes(@example_path)
          
          expect(subject.handle(path: @example_path, revision: 'HEAD')).to match(['api', 'core', 'web'].sort)
        end
      end

      context "for file without package" do
        before do
          git_initialize_repository(@example_path)
          git_commit_changes(@example_path)

          File.open(File.join(@example_path, 'domain/missing_package_class.rb'), 'w') do |f|
            f.write <<~EOF
              class MissingPackageClass
              end
            EOF
          end
        end

        it "returns empty array" do
          git_index_changes(@example_path)

          expect(subject.handle(path: @example_path, revision: 'HEAD')).to eq([])
        end
      end
    end

    context "when git repository is not initialized" do
      it "raises Rdm::Errors::GitRepositoryNotInitialized error" do
        expect{
          subject.handle(path: @example_path, revision: 'HEAD')
        }.to raise_error(Rdm::Errors::GitRepositoryNotInitialized)
      end
    end
  end
end