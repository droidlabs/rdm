require 'spec_helper'

describe Rdm::ConfigManager do
  subject { Rdm::ConfigManager.new }

  let(:example_path) {
    Pathname.new(
      File.join(File.expand_path('../../../', __FILE__), 'example')
    )
  }
  let(:config_manager) { Rdm::ConfigManager.new }
  let(:source_file) { example_path.join('Rdm.packages').to_s }
  let(:source) { Rdm::SourceParser.read_and_init_source(source_file)}

  describe "#load_config" do
    context "config.default_path" do
      let(:config){ Rdm::Config.build(name: "name", default_path: "configs/app/default.yml", role_path: nil) }
      it "works" do
        config_manager.load_config(config, source: source)
      end
    end

    context "config.role_path" do
      let(:config){ Rdm::Config.build(name: "name", default_path: nil, role_path: "configs/app/production.yml") }
      it "works" do
        config_manager.load_config(config, source: source)
      end
    end
  end

  describe "#update_using_file" do
    context "file missing and raise_if_missing=true" do
      let(:config){ Rdm::Config.build(name: "name", default_path: "configs/app/not-there.yml", role_path: nil) }
      it "raises" do
        expect{
          config_manager.load_config(config, source: source)
        }.to raise_error(RuntimeError, Regexp.new("Config file is not found at path"))
      end
    end
  end

  describe "#update_using_file" do
    let(:fixtures_path) {
      File.join(File.expand_path("../../", __FILE__), 'fixtures')
    }

    before :each do
      subject.update_using_file(File.join(fixtures_path, "config.yml"))
    end

    it "parses yml with erb correctly" do
      expect(subject.development.foo).to eq("bar")
    end
  end

  describe "#update_using_hash" do
    before :each do
      subject.update_using_hash(
        database: {
          username: "foo",
          password: "bar"
        },
        lib_name: "rdm",
        version: 1,
        published: true,
        draft: false,
        features: ["dependency_manager", "config_manager"]
      )
    end

    it "returns given value for string" do
      expect(subject.lib_name).to eq("rdm")
    end

    it "returns given value for int" do
      expect(subject.version).to eq(1)
    end

    it "returns given value for true bool" do
      expect(subject.published).to eq(true)
    end

    it "returns given value for false bool" do
      expect(subject.draft).to eq(false)
    end

    it "returns given value for array" do
      expect(subject.features).to eq(["dependency_manager", "config_manager"])
    end

    it "creates another child scope for nested hash" do
      expect(subject.database).to be_instance_of(Rdm::ConfigScope)
      expect(subject.database.username).to eq("foo")
      expect(subject.database.password).to eq("bar")
    end

    context "when already has config" do
      before :each do
        subject.update_using_hash(
          database: {
            username: "new_username",
            password: "new_password"
          }
        )
      end

      it "keeps old configs" do
        expect(subject.lib_name).to eq('rdm')
      end

      it "rewrites new configs" do
        expect(subject.database.username).to eq('new_username')
      end
    end
  end

  describe "to_h" do
    before :each do
      subject.update_using_hash(
        site_name: "Sample app",
        database: {
          username: "username",
          password: "password"
        }
      )
    end

    it "returns attributes in root scope" do
      expect(subject.to_h["site_name"]).to eq("Sample app")
    end

    it "returns attributes in child scope" do
      expect(subject.to_h["database"]["username"]).to eq("username")
    end
  end
end
