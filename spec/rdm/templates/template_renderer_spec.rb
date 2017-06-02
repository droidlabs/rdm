require 'spec_helper'

describe Rdm::Templates::TemplateRenderer do
  subject { described_class }

  let(:example_string)      { '/tmp/example_project/<%=entity_name%>/services/<%=service_name%>/' }
  let(:no_variables_string) { "/tmp/example_project/\nhello" }
  let(:entity_name)         { 'users' } 
  let(:service_name)        { 'creator' }

  describe '::handle' do
    context "without undefined variables" do
      it "replace variables to real values for specified string" do
        expect(
          subject.handle(example_string, {
            entity_name:  entity_name,
            service_name: service_name
          })
        ).to eq('/tmp/example_project/users/services/creator/')
      end
    end

    context "with undefined variables" do
      it "raises Rdm::Errors::TemplateVariableNotDefined" do
        expect {
          subject.handle(example_string)
        }.to raise_error(Rdm::Errors::TemplateVariableNotDefined)
      end
    end

    context "without variables" do
      it "not modified string without any variables" do
        expect(
          subject.handle(no_variables_string, {
            entity_name:  entity_name,
            service_name: service_name
          })
        ).to eq("/tmp/example_project/\nhello")
      end
    end
  end
end