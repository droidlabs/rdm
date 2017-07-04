require 'spec_helper'

describe Rdm::CLI::CompilePackage do
  include ExampleProjectHelper

  subject                     { described_class }
  let(:default_compile_path)  { '/tmp/rdm_compiled' }
  let(:new_compile_path)      { '/tmp/new_rdm_compiled' }

  describe "::compile" do
    before :each do
      initialize_example_project
    end

    after :each do
      reset_example_project
      FileUtils.rm_rf(default_compile_path)
      FileUtils.rm_rf(new_compile_path)
    end

    context "setup compile_path at Rdm.packages" do
      it "use default value for compile_path" do
        expect {
          subject.compile(
            project_path:        example_project_path,
            package_name:        'core',
            overwrite_directory: ->() { true }
          )
        }.to output(
          <<~EOF
            The following packages were copied:
            Core
            Repository
          EOF
        ).to_stdout
      end
    end

    context "with invalid params" do
      context "project_path" do
        it "raises error if rdm is not initialized" do
          expect {
            subject.compile(
              project_path: File.dirname(example_project_path),
              compile_path: new_compile_path,
              package_name: 'core'
            )
          }.to output(
            "Rdm.packages was not found. Run 'rdm init' to create it\n"
          ).to_stdout
        end
      end

      context "compile_path" do
        it "raises error if empty" do
          Rdm::Utils::FileUtils.change_file(rdm_source_file) do |line|
            next if line.include?('compile_path')
          end

          expect {
            subject.compile(
              project_path: example_project_path,
              compile_path: '',
              package_name: 'core'
            )
          }.to output(
            "Destination path was not specified. Ex: rdm compile.package package_name --path FOLDER_PATH\n"
          ).to_stdout
        end 
      end

      context "package name" do
        it "raises error if empty" do
          expect {
            subject.compile(
              project_path: example_project_path,
              compile_path: new_compile_path,
              package_name: ''
            )
          }.to output(
            "Package name was not specified. Ex: rdm compile.package PACKAGE_NAME\n"
          ).to_stdout
        end
      end

      context "with valid params" do
        context "if directory exists" do
          before do
            FileUtils.mkdir_p(new_compile_path)
            File.open(File.join(new_compile_path, 'old_file.txt'), 'w') {|f| f.write("Old File")}
          end

          it "ask to overwriting the directory" do
            expect {
              subject.compile(
                project_path:        example_project_path,
                compile_path:        new_compile_path,
                package_name:        'core',
                overwrite_directory: ->() { true }
              )
            }.to output(
              <<~EOF
                Destination directory exists. Overwrite it? (y/n)
                The following packages were copied:
                Core
                Repository
              EOF
            ).to_stdout
          end
        end
      end
    end
  end
end