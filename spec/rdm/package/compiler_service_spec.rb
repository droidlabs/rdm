require 'spec_helper'

describe Rdm::Packages::CompilerService do
  include ExampleProjectHelper

  subject                       { described_class }
  let(:source_parser)           { Rdm::SourceParser }
  let(:source_path)             { File.join(compile_path, Rdm::SOURCE_FILENAME) }
  let(:fixed_compile_path)      { "/tmp/rdm/custom_name" }
  let(:compile_path_template)   { "/tmp/rdm/:package_name" }

  def compile_path(package_name)
    compile_path_template.gsub(/:package_name/, package_name)
  end

  def source_path(package_name)
    File.join(compile_path(package_name), Rdm::SOURCE_FILENAME)
  end

  describe "::compile" do
    before { initialize_example_project }
    
    after do
      reset_example_project
      FileUtils.rm_rf File.dirname(fixed_compile_path)
    end

    context "to existing directory" do
      before do
        subject.compile(
          package_name: 'web',
          compile_path: fixed_compile_path,
          project_path: example_project_path
        )
      end

      context 'deletes old directory and creates new package' do
        before do
          subject.compile(
            package_name: 'core', 
            compile_path: fixed_compile_path,
            project_path: example_project_path
          ) 
        end
        
        it "deletes old unused package from file structure" do
          expect(
            File.exists?(File.join(fixed_compile_path, 'application/web/package/web.rb'))
          ).to be false
        end

        it "deletes old unused package from Rdm.packages" do
          package_names = source_parser
            .read_and_init_source(source_path('custom_name'))
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
          package_name: 'repository', 
          compile_path: compile_path_template,
          project_path: example_project_path
        ) 
      end
      
      it "creates folder" do
        expect(Dir.exists?(compile_path('repository'))).to be true
      end

      it "creates Rdm.packges" do
        expect(File.exists?(source_path('repository'))).to be true
      end

      it "copies files structure from original package" do
        expect(
          File.exists?(File.join(compile_path('repository'), 'infrastructure/repository/package/repository.rb'))
        ).to be true
      end

      it "add only required package name to Rdm.packages" do
        package_names = source_parser
          .read_and_init_source(source_path('repository'))
          .packages
          .values
          .map(&:name)

        expect(package_names).to include("repository")
        expect(package_names.size).to eq(1)
      end
    end

    context "package with dependencies" do
      before do
        subject.compile(
          package_name: 'web',
          compile_path: compile_path_template,
          project_path: example_project_path
        )
      end

      it "copies files structure for each dependent package" do
        expect(
          File.exists?(File.join(compile_path('web'), 'domain/core/package/core.rb'))
        ).to be true

        expect(
          File.exists?(File.join(compile_path('web'), 'application/web/package/web.rb'))
        ).to be true
      end

      it "add only required package name to Rdm.packages" do
        package_names = source_parser
          .read_and_init_source(source_path('web'))
          .packages
          .values
          .map(&:name)

        expect(package_names).to include("web")
        expect(package_names).to include("core")
        expect(package_names).to include("repository")
        expect(package_names.size).to eq(3)
      end
    end
  end
end