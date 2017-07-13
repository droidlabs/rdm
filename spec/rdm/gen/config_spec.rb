require 'spec_helper'

describe Rdm::Gen::Config do
  include ExampleProjectHelper

  subject { described_class }

  describe "::generate" do
    before { initialize_example_project }
    after  { reset_example_project }

    context "sample config" do
      before do
        subject.generate(
          config_name:  'mailing_system',
          current_path: example_project_path
        )
      end

      it "generates sample config" do
        FileUtils.cd(example_project_path) do
          ensure_exists("configs/mailing_system/default.yml")
        end
      end

      it "add config line to Rdm.packages" do
        ensure_content(rdm_source_file, 'config :mailing_system')
      end
    end
  end
end