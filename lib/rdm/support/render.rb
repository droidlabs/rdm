# http://stackoverflow.com/questions/8954706/render-an-erb-template-with-values-from-a-hash
require 'erb'
require 'ostruct'

module Rdm
  module Support
    class Render < OpenStruct
      def self.render(template, locals)
        new(locals).render(template)
      end

      def render(template)
        ERB.new(template).result(binding)
      end
    end
  end
end
