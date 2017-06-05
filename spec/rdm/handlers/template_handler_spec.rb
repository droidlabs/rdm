require 'spec_helper'

describe Rdm::Handlers::TemplateHandler do
  include ExampleProjectHelper

  subject { Rdm::Handlers::TemplateHandler }

  let(:template_name) { 'repository' }
  let(:local_path)    { 'domain/infrastructure' }

  before do
    @project_path     = initialize_example_project
    @created_abs_path = File.join(@project_path, local_path)
  end

  after do
    reset_example_project(path: @project_path)
  end

  describe "::generate" do
    context "for existing template" do
      it "creates all files from template to destination folder" do
        subject.generate(
          template_name:    template_name, 
          local_path:       local_path,
          current_path:     @project_path,
          locals:           {
            name:                   'users',
            package_name_camelized: 'User'
          }
        )

        ensure_exists(File.join(@created_abs_path, 'dao/users_dao.rb'))
        ensure_exists(File.join(@created_abs_path, 'mapper/users_mapper.rb'))
        ensure_exists(File.join(@created_abs_path, 'repository/users_repository.rb'))
      end

      it "creates files with proper content" do
        subject.generate(
          template_name:    template_name, 
          local_path:       local_path,
          current_path:     @project_path,
          locals:           {
            name:                   'users',
            package_name_camelized: 'User'
          }
        )

        ensure_content(
          File.join(@created_abs_path, 'dao/users_dao.rb'), 
          "class users\nend"
        )
      end

      it "skips erb files" do
        subject.generate(
          template_name:    template_name, 
          local_path:       local_path,
          current_path:     @project_path,
          locals:           {
            name:                   'users',
            package_name_camelized: 'User'
          }
        )
        ensure_content(
          File.join(@created_abs_path, 'views/users.html.erb'), 
          "class <%=name%>\nend"
        )
      end
    end
  end
end