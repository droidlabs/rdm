require "spec_helper"

describe Rdm::Handlers::DiffPackageHandler do
  include SetupHelper

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
          %x( cd #{@example_path} && git init && git add . && git commit -am "Initial commit" )

          File.open(File.join(@example_path, 'application/web/package/web/new_controller.rb'), 'w') do |f| 
            f.write <<~EOF
              class Web::NewController
              end
            EOF
          end
        end

        it "returns only modified packages" do
          %x( cd #{@example_path} && git add . )
          
          expect(subject.handle(path: @example_path, git_point: 'HEAD')).to eq(["web"])
        end
      end

      context "for package with dependencies" do
        before do
          %x( cd #{@example_path} && git init && git add . && git commit -am "Initial commit" )

          File.open(File.join(@example_path, 'domain/core/package/core/new_service.rb'), 'w') do |f| 
            f.write <<~EOF
              class Core::NewService
              end
            EOF
          end
        end

        it "returns array of modified and dependend packages for indexed changes" do
          %x( cd #{@example_path} && git add . )
          
          expect(subject.handle(path: @example_path, git_point: 'HEAD')).to match(['web', 'core'])
        end
      end

      context "for file without package" do
        before do
          %x( cd #{@example_path} && git init && git add . && git commit -am "Initial commit" )

          File.open(File.join(@example_path, 'domain/missing_package_class.rb'), 'w') do |f|
            f.write <<~EOF
              class MissingPackageClass
              end
            EOF
          end
        end

        it "returns empty array" do
          %x( cd #{@example_path} && git add . )

          expect(subject.handle(path: @example_path, git_point: 'HEAD')).to eq([])
        end
      end
    end

    context "when git repository is not initialized" do
      it "raises Rdm::Errors::GitRepositoryNotInitialized error" do
        expect{
          subject.handle(path: @example_path, git_point: 'HEAD')
        }.to raise_error(Rdm::Errors::GitRepositoryNotInitialized)
      end
    end
  end
end