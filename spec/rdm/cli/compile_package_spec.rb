require 'spec_helper'

describe Rdm::CLI::CompilePackage do
  include ExampleProjectHelper

  subject { described_class }

  describe "::compile" do
    before do
      @project_path = initialize_example_project
      @compile_path = '/tmp/example_compile'
    end

    after do
      reset_example_project(path: @project_path)
      reset_example_project(path: @compile_path)
    end

    context "setup compile_path at Rdm.packages" do
      it "use default value for compile_path" do
        expect {
          subject.compile(
            project_path:        @project_path,
            package_name:        'core',
            overwrite_directory: ->() { true }
          )
        }.to output(
          <<~EOF
            The following packages were successfully compiled:
            Core
          EOF
        ).to_stdout
      end
    end

    context "with invalid params" do
      context "project_path" do
        it "raises error if rdm is not initialized" do
          expect {
            subject.compile(
              project_path: File.dirname(@project_path),
              compile_path: @compile_path,
              package_name: 'core'
            )
          }.to output(
            "Source file doesn't exist. Type 'rdm init' to create Rdm.packages\n"
          ).to_stdout
        end
      end

      context "compile_path" do
        it "raises error if empty" do
          File.open(File.join(@project_path, Rdm::SOURCE_FILENAME), 'w') do |f| 
            f.write <<~EOF
              setup do
                role                "production"
                configs_dir         "configs"
                config_path         ":configs_dir/:config_name/default.yml"
                role_config_path    ":configs_dir/:config_name/:role.yml"
                package_subdir_name "package"
                compile_ignore_files [
                  '.gitignore',
                  '.byebug_history',
                  '.irbrc',
                  '.rspec',
                  '*_spec.rb',
                  '*.log'
                ]
                compile_add_files [
                  'Gemfile',
                  'Gemfile.lock'
                ]
              end

              package "application/web"
              package "domain/core"
              package "subsystems/api"
            EOF
          end
          debugger
          expect {
            subject.compile(
              project_path: @project_path,
              compile_path: "",
              package_name: 'core'
            )
          }.to output(
            "Compile path was not specified!\n"
          ).to_stdout
        end 
      end

      context "package name" do
        it "raises error if empty" do
          expect {
            subject.compile(
              project_path: @project_path,
              compile_path: @compile_path,
              package_name: ''
            )
          }.to output(
            "Package name was not specified!\n"
          ).to_stdout
        end
      end

      context "with valid params" do
        context "if directory exists" do
          before do
            FileUtils.mkdir_p(@compile_path)
            File.open(File.join(@compile_path, 'old_file.txt'), 'w') {|f| f.write("Old File")}
          end

          it "ask to overwriting the directory" do
            expect {
              subject.compile(
                project_path:        @project_path,
                compile_path:        @compile_path,
                package_name:        'core',
                overwrite_directory: ->() { true }
              )
            }.to output(
              <<~EOF
                Compile directory exists. Overwrite it? (y/n)
                The following packages were successfully compiled:
                Core
              EOF
            ).to_stdout
          end
        end

        it "compile packages to selected directory" do

        end
      end
    end
  end
end