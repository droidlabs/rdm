require 'spec_helper'

describe Rdm::Handlers::TemplateHandler do
  include ExampleProjectHelper

  subject { Rdm::Handlers::TemplateHandler }

  let(:template_name)     { 'repository' }
  let(:local_path)        { 'domain/infrastructure' }
  let(:created_abs_path)  { File.join(example_project_path, local_path) }
  let(:stdout)            { SpecLogger.new }

  before { initialize_example_project } 
  after  { reset_example_project }

  describe "::generate" do
    context "for existing template" do
      it "creates all files from template to destination folder" do
        subject.generate(
          template_name:    template_name, 
          local_path:       local_path,
          current_path:     example_project_path,
          locals:           {
            name: 'users'
          }
        )

        ensure_exists(File.join(created_abs_path, 'dao/users_dao.rb'))
        ensure_exists(File.join(created_abs_path, 'mapper/users_mapper.rb'))
        ensure_exists(File.join(created_abs_path, 'repository/users_repository.rb'))
      end

      it "creates files with proper content" do
        subject.generate(
          template_name:    template_name, 
          local_path:       local_path,
          current_path:     example_project_path,
          locals:           {
            name: 'users'
          }
        )

        ensure_content(
          File.join(created_abs_path, 'dao/users_dao.rb'), 
          "require 'users_repository'\n\nclass Users\nend"
        )
      end

      it "skips erb files" do
        subject.generate(
          template_name:    template_name, 
          local_path:       local_path,
          current_path:     example_project_path,
          locals:           {
            name: 'users'
          }
        )

        ensure_content(
          File.join(created_abs_path, 'views/users.html.erb'), 
          "class <%=name%>\nend"
        )
      end

      context "asks for undefined variables" do
        before do
          subject.generate(
            template_name:    template_name, 
            local_path:       local_path,
            current_path:     example_project_path,
            locals:           {},
            stdout:           stdout,
            stdin:            SpecLogger.new(stdin: "order\n")
          )
        end
        
        it "output ask variable text" do
          expect(stdout.output).to match([
            "Undefined variables were found:", 
            "  1. name", "Type value for 'name': "
          ])
        end
        
        it "creates file with correct variable" do
            ensure_content(
            File.join(created_abs_path, 'dao/order_dao.rb'), 
            "require 'order_repository'\n\nclass Order\nend"
          )
        end

      end
    end
  end
end