module Rdm
  module Support
    class Template
      attr_accessor :tmpl_path
      def initialize(tmpl_path = nil)
        @tmpl_path = construct_path(tmpl_path)
      end

      def content(file, locals = {})
        path    = tmpl_path.join(file)
        content = File.read(path)
        Rdm::Support::Render.render(content, locals)
      end

      def construct_path(some_path = nil)
        Pathname.new(
          File.expand_path(
            (some_path || default_templates_path)
          )
        )
      end

      def default_templates_path
        File.expand_path(
          File.join(File.dirname(__FILE__), '..', 'templates')
        )
      end
    end
  end
end
