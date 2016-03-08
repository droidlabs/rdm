require 'spec_helper'

describe Rdm::ConfigManager do
  subject { Rdm::ConfigManager.new }

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
      puts subject.inspect
      expect(subject.to_h["site_name"]).to eq("Sample app")
    end

    it "returns attributes in child scope" do
      expect(subject.to_h["database"]["username"]).to eq("username")
    end
  end
end