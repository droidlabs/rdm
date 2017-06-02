module Rdm
  module Templates
    class TemplateDetector
      DEFAULT_TEMPLATES_DIRECTORY = File.expand_path(__dir__)

      def initialize(project_path)
        @all_templates_directory ||= File.join(project_path, ".rdm", "templates")
      end


      def detect_template_folder(template_name)
        template_folder = File.join(@all_templates_directory, template_name.to_s)

        raise Rdm::Errors::TemplateDoesNotExist unless Dir.exist?(template_folder)

        template_folder
      end

      def template_file_path(template_name, relative_path)
        file_path = [detect_template_folder(template_name), DEFAULT_TEMPLATES_DIRECTORY]
          .map {|folder| File.join(folder, relative_path)}
          .detect {|file| File.exists?(file)}

        raise Rdm::Errors::TemplateFileDoesNotExists if file_path.nil?

        file_path
      end
    end
  end
end