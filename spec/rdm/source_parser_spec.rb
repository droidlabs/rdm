require 'spec_helper'

describe Rdm::SourceParser do
  include ExampleProjectHelper

  describe "#parse" do
    subject { Rdm::SourceParser }

    let(:fixtures_path) {
      File.join(File.expand_path("../../", __FILE__), 'fixtures')
    }

    let(:source_path) {
      File.join(fixtures_path, "SampleSource.rb")
    }

    let(:source_content) {
      File.read(source_path)
    }

    before :each do
      @source = subject.read_and_init_source(source_path, stdout: SpecLogger.new)
    end

    it "returns Source object" do
      expect(@source.is_a?(Rdm::Source)).to be_truthy
    end

    it "parses all packages paths" do
      paths = @source.package_paths
      expect(paths.count).to be(2)
      expect(paths).to include("application/web")
      expect(paths).to include("domain/core")
    end

    it "parses all config names" do
      names = @source.config_names
      expect(names.count).to be(1)
      expect(names).to include("database")
    end
  end


  describe "#parse on real project" do
    subject { Rdm::SourceParser }

    let(:fixtures_path) {
      File.join(File.expand_path("../../../", __FILE__), 'example')
    }

    let(:source_path) {
      File.join(fixtures_path, "Rdm.packages")
    }

    let(:source_content) {
      File.read(source_path)
    }

    before :each do
      @source = subject.read_and_init_source(source_path, stdout: SpecLogger.new)
    end

    it "returns Source object" do
      expect(@source.is_a?(Rdm::Source)).to be_truthy
    end

    it "parses all packages paths" do
      paths = @source.package_paths
      expect(paths.count).to be(4)
      expect(paths).to include("application/web")
      expect(paths).to include("domain/core")
    end

    it "parses all config names" do
      names = @source.config_names
      expect(names.count).to be(2)
      expect(names).to include("database")
    end
  end

  describe "::read_and_init_source" do
    before { initialize_example_project }
    after  { reset_example_project }

    subject { described_class }
    let(:stdout) { SpecLogger.new }

    describe "#init_and_set_env_variables" do
      context "with defined role" do
        it "load env_file variables into ENV hash" do
          subject.read_and_init_source(@rdm_source_file)

          expect(ENV['EXAMPLE_API_KEY']).to eq('example_key_value')
          expect(ENV['APP_NAME']).to eq('Application')
        end
      end

      context "with undefined role" do
        it "puts warning message" do
          Rdm::Utils::FileUtils.change_file @rdm_source_file do |line|
            line.include?('env_file_name "production"') ? 'env_file_name "stading"' : line
          end
          
          subject.read_and_init_source(@rdm_source_file, stdout: stdout)

          expect(stdout.output).to include("WARNING! Environment file 'stading' was not found. Please, add /tmp/example/env_files/stading.env file...")
        end
      end

      context "when try to overwrite ENV variable" do
        before do
          ENV['RUBY_ENV'] = 'test'
          
          subject.read_and_init_source(@rdm_source_file, stdout: stdout)
        end

        it 'puts warning message' do
          expect(stdout.output).to include("WARNING! Environment file 'production' overwrites ENV['RUBY_ENV'] variable from 'test' to 'production' ...")
        end

        it 'overwrites ENV variable' do
          expect(ENV['RUBY_ENV']).to eq('production')
          expect(ENV['APP_NAME']).to eq('Application')
        end
      end
    end
  end
end
