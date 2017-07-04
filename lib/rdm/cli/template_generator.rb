module Rdm
  module CLI
    class TemplateGenerator
      class << self
        def run(template_name:, current_path:, local_path:, locals:)
          TemplateGenerator.new(
            template_name: template_name,
            current_path:  current_path,
            local_path:    local_path,
            locals:        locals
          ).run
        end
      end

      def initialize(template_name:, current_path:, local_path:, locals:)
        @template_name = template_name
        @current_path  = current_path
        @local_path    = local_path
        @locals        = locals
      end

      def run
        Rdm::Handlers::TemplateHandler.generate(
          template_name: @template_name,
          current_path:  @current_path,
          local_path:    @local_path,
          locals:        @locals
        )
      rescue Rdm::Errors::TemplateDoesNotExist
        puts "Template '#{@template_name}' does not exist. Create new at #{File.join(@current_path, '.rdm/templates/', @template_name)} folder"
      rescue Rdm::Errors::SourceFileDoesNotExist => e
        puts e.message
      rescue Rdm::Errors::TemplateFileExists => e
        puts "File #{e.message} already exists. Try to user another variable name"
      end
    end
  end
end