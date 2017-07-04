module Rdm
  module Templates
    class TemplateRenderer
      TEMPLATE_VARIABLE = /<%=\s*([\w\d-]+)\s*%>/i

      class << self
        def handle(template, locals = {})
          Rdm::Templates::TemplateRenderer.new(template, locals).handle
        end

        def get_undefined_variables(template, locals = {})
          Rdm::Templates::TemplateRenderer.new(template, locals).get_undefined_variables
        end
      end

      def initialize(template, locals)
        @template = template
        @locals = locals
      end 

      def handle 
        raise Rdm::Errors::TemplateVariableNotDefined, get_undefined_variables.map(&:to_s).join(';') if get_undefined_variables.any?

        Rdm::Utils::RenderUtil.render(@template, @locals)
      end

      def get_undefined_variables
        get_template_variables - get_passed_variables
      end

      private

      def get_template_variables
        @template
          .scan(TEMPLATE_VARIABLE)
          .flatten
          .map(&:intern)
          .uniq
      end

      def get_passed_variables
        @locals
          .keys
          .uniq
          .map(&:intern)
      end
    end
  end
end