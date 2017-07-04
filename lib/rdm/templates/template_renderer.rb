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
        @locals   = locals
        @undefined_variables = []
      end 

      def handle 
        raise Rdm::Errors::TemplateVariableNotDefined, get_undefined_variables.map(&:to_s).join(';') if get_undefined_variables.any?

        Rdm::Utils::RenderUtil.render(@template, @locals)
      end

      def get_undefined_variables
        Rdm::Utils::RenderUtil.render(@template, @locals)

        @undefined_variables
      rescue NameError => e
        @locals[e.name] = e.name.to_s
        @undefined_variables.push(e.name)

        retry
      end

      private

      def get_template_variables
        Rdm::Utils::RenderUtil.render(@template, {})
      rescue NameError => e
        @locals

        get_template_variables(@template, fake_locals, undefined_variables)
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