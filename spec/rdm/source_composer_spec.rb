require 'spec_helper'

describe Rdm::SourceComposer do
  include ExampleProjectHelper

  subject { described_class }

  before { initialize_example_project }
  after  { reset_example_project }

  describe '::run' do
    context 'setup block' do
      before do
        @rdm_source = Rdm::SourceParser.read_and_init_source(rdm_source_file)
        described_class.run(@rdm_source)
      end

      it "composes with explicit options" do
        ensure_content(rdm_source_file, 'role "production"')
        ensure_content(rdm_source_file, 'env_file_name "production"')
        ensure_content(rdm_source_file, 'env_files_dir "env_files"')
        ensure_content(rdm_source_file, 'config_path ":configs_dir/:config_name/default.yml"')
        ensure_content(rdm_source_file, 'role_config_path ":configs_dir/:config_name/:role.yml"')
        ensure_content(rdm_source_file, 'package_subdir_name "package"')
        ensure_content(rdm_source_file, 'compile_path "/tmp/rdm/:package_name"')
      end

      it "composes with default options" do
        ensure_content(rdm_source_file, 'silence_missing_package false')
        ensure_content(rdm_source_file, 'silence_missing_package_file true') # From 'spec_helper' settings, should be false
        expect(
          File.read(rdm_source_file)
        ).to include('compile_ignore_files [".gitignore", ".byebug_history", ".irbrc", ".rspec", "*_spec.rb", "*.log"]')
        expect(
          File.read(rdm_source_file)
        ).to include('compile_add_files ["Gemfile", "Gemfile.lock"]')
      end
    end

    context 'configs' do
      before do
        @rdm_source = Rdm::SourceParser.read_and_init_source(rdm_source_file)
        @rdm_source.config(:mailing_system)
        described_class.run(@rdm_source)
      end

      it "composes with old configs" do
        ensure_content(rdm_source_file, 'config :database')
        ensure_content(rdm_source_file, 'config :app')
      end

      it "composes with new configs" do
        ensure_content(rdm_source_file, 'config :mailing_system')
      end
    end

    context 'packages' do
      before do
        @rdm_source = Rdm::SourceParser.read_and_init_source(rdm_source_file)
        @rdm_source.package('mailing_system')
        described_class.run(@rdm_source)
      end
      
      it "composes with old configs" do
        ensure_content(rdm_source_file, 'package "server"')
        ensure_content(rdm_source_file, 'package "domain/core"')
        ensure_content(rdm_source_file, 'package "infrastructure/repository"')
        ensure_content(rdm_source_file, 'package "application/web"')
      end

      it "composes with new configs" do
        ensure_content(rdm_source_file, 'package "mailing_system"')
      end
    end
  end
end