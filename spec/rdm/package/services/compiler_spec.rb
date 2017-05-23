require 'spec_helper'

describe Rdm::Packages::Services::Compiler do
  include ExampleProjectHelper

  subject { described_class }
  let(:source_parser) { Rdm::SourceParser }
  let(:source_path) { File.join(@compile_path, Rdm::SOURCE_FILENAME) } 

  describe "::compile" do
    before do
      @project_path = initialize_example_project(path: '/tmp/example')
      @compile_path = "/tmp/example_compile"
    end

    context "to existing directory" do
      before do
        subject.compile(
          package_name: 'web',
          compile_path: @compile_path,
          project_path: @project_path
        )
      end

      context 'deletes old directory and creates new package' do
        before do
          subject.compile(
            package_name: 'core', 
            compile_path: @compile_path,
            project_path: @project_path
          ) 
        end

        it "deletes old unused package from file structure" do
          expect(
            File.exists?(File.join(@compile_path, 'application/web/package/web.rb'))
          ).to be false
        end

        it "deletes old unused package from Rdm.packages" do
          package_names = source_parser
            .read_and_init_source(source_path)
            .packages
            .values
            .map(&:name)

          expect(package_names).to_not include("web")
          expect(package_names).to     include("core")
        end
      end
    end

    context "package without dependencies" do
      before do
        subject.compile(
          package_name: 'core', 
          compile_path: @compile_path,
          project_path: @project_path
        ) 
      end
      
      it "creates folder" do
        expect(Dir.exists?(@compile_path)).to be true
      end

      it "creates Rdm.packges" do
        expect(File.exists?(source_path)).to be true
      end

      it "copies files structure from original package" do
        expect(
          File.exists?(File.join(@compile_path, 'domain/core/package/core.rb'))
        ).to be true
      end

      it "add only required package name to Rdm.packages" do
        package_names = source_parser
          .read_and_init_source(source_path)
          .packages
          .values
          .map(&:name)

        expect(package_names).to include("core")
        expect(package_names.size).to eq(1)
      end
    end

    context "package with dependencies" do
      before do
        subject.compile(
          package_name: 'web',
          compile_path: @compile_path,
          project_path: @project_path
        )
      end

      it "copies files structure for each dependent package" do
        expect(
          File.exists?(File.join(@compile_path, 'domain/core/package/core.rb'))
        ).to be true

        expect(
          File.exists?(File.join(@compile_path, 'application/web/package/web.rb'))
        ).to be true
      end

      it "add only required package name to Rdm.packages" do
        package_names = source_parser
          .read_and_init_source(source_path)
          .packages
          .values
          .map(&:name)

        expect(package_names).to include("web")
        expect(package_names).to include("core")
        expect(package_names.size).to eq(2)
      end
    end

    after do
      reset_example_project(path: @project_path)
      reset_example_project(path: @compile_path)
    end
  end
end