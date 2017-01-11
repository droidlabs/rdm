require "spec_helper"

describe "Rdm::Support::Template" do
  let(:template) {Rdm::Support::Template.new}
  describe ":default_templates_path" do
    it "is correct" do
      expect(template.default_templates_path.to_s).to match(/lib\/rdm\/templates$/)
    end
  end

  describe ":content" do
    it "renders template content without locals" do
      expect(template.content("package/.rspec")).to eq("--color\n--require spec_helper\n")
    end

    it "renders template content without locals" do
      expect(template.content("package/main_module_file.rb.erb", {package_name_camelized: "Some"})).to eq("module Some\n\nend\n")
    end
  end
end
