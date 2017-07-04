require 'spec_helper'

describe Rdm::Templates::TemplateDetector do
  subject { described_class.new(project_path) }

  let(:project_path) { File.join(File.expand_path('../../../..', __FILE__), 'example')} 

  context "#detect_template_folder" do
    context "for existing template" do
      it "returns absolute path to templates folder" do
        expect(
          subject.detect_template_folder(:repository)
        ).to eq(File.join(project_path, '.rdm/templates/repository'))
      end
    end 

    context "for missing template" do
      it "raises Rdm::Errors::TemplateDoesNotExist error" do
        expect {
          subject.detect_template_folder(:invalid_repository)
        }.to raise_error(Rdm::Errors::TemplateDoesNotExist)
      end
    end
  end

  context "#check_template_file" do
    context "for file in projects templates directory folder" do

    end

    context "for file in gem templates directory folder" do

    end

    context "for missing file" do

    end
  end
end