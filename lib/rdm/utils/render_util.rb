require 'erb'

module Rdm
  module Utils
    class RenderUtil
      def self.render(template, locals)
        include Rdm::RenderHelper if defined?(Rdm::RenderHelper)
        new(locals).render(template)
      end

      def initialize(locals = {})
        @render_binding = binding
        @locals         = locals
      end

      def render(template)
        @locals.each { |variable, value| @render_binding.local_variable_set(variable, value) }
        
        ERB.new(template).result(@render_binding)
      end
    end
  end
end
