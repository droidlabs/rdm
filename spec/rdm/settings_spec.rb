require 'spec_helper'

describe Rdm::Settings do
  subject { Rdm::Settings.new }

  describe "#fetch_setting" do
    it "writes setting if value provided" do
      expect(subject.send(:read_setting, :test)).to be_nil
      subject.fetch_setting(:test, "test value")
      expect(subject.send(:read_setting, :test)).to eq("test value")
    end

    it "reads setting if no value provided" do
      subject.send(:write_setting, :test, "test value")
      expect(subject.fetch_setting(:test)).to eq("test value")
    end
  end

  describe "#read_setting" do
    it "returns setting if it's boolean" do
      subject.send(:write_setting, :bool_value, true)
      expect(subject.read_setting(:bool_value)).to eq(true)
    end

    it "returns result of proc if it's a proc" do
      proc_value = proc {
        "proc value"
      }
      subject.send(:write_setting, :proc_value, proc_value)
      expect(subject.read_setting(:proc_value)).to eq("proc value")
    end

    it "replaces variables if it's a string" do
      subject.role("test")
      subject.fetch_setting("some-path", "/path/:role.yml")
      expect(subject.read_setting("some-path")).to eq("/path/test.yml")
    end

    it "replaces additional variables if it's a string" do
      subject.role("foo")
      subject.fetch_setting("some-path", "/path/:role/:myvar.yml")
      expect(subject.read_setting("some-path", vars: {myvar: "bar"})).to eq("/path/foo/bar.yml")
    end
  end
end