require 'erb'
require 'ostruct'

module Rdm
  module Utils
    class RenderUtil < OpenStruct
      def self.render(template, locals)
        new(locals).render(template)
      end

      def render(template)
        ERB.new(template).result(binding)
      end
    end
  end
end
