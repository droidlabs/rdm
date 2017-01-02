require 'fileutils'
require 'pathname'
require "active_support/inflector"


module Rdm
  module Gen
    class Init
      class << self
        def generate(current_dir:, test: "rspec", console: "irb")
          Rdm::Gen::Init.new(current_dir: current_dir, test: test, console: console).generate
        end
      end

      attr_accessor :current_dir, :test, :console
      def initialize(current_dir:, test:, console:)
        @current_dir = File.expand_path(current_dir)
        @test        = test
        @console     = console
      end

      def generate
        check_preconditions!

        Dir.chdir(current_dir) do
          ensure_file(['.gitignore'])
          ensure_file(
            ["Rdm.packages"],
            template_content("Rdm.packages.erb")
          )

          ensure_file(
            ["Gemfile"],
            template_content("Gemfile.erb")
          )

          ensure_file(
            ["Readme.md"],
            template_content("Readme.md.erb")
          )
          move_templates
        end
      end

      def check_preconditions!
        if File.exist?(File.join(current_dir, Rdm::SOURCE_FILENAME))
          raise Rdm::Errors::ProjectAlreadyInitialized, "#{current_dir} has already #{Rdm::SOURCE_FILENAME}"
        end
      end

      def move_templates
        Dir.chdir(templates_path) do
          copy_template("tests/run")
        end
      end

    private
      def ensure_file(path_array, content="")
        filename = File.join(*path_array)
        FileUtils.mkdir_p(File.dirname(filename))
        File.write(filename, content)
      end

      def copy_template(filepath, target_name=nil)
        from          = filepath
        target_name ||= filepath
        to            = File.join(current_dir, target_name)
        FileUtils.mkdir_p(File.dirname(to))
        # copy_entry(src, dest, preserve = false, dereference_root = false, remove_destination = false)
        FileUtils.copy_entry(from, to, true, false, true)
      end

      def template_content(file, locals={})
        template_path    = templates_path.join(file)
        template_content = File.read(template_path)
        Rdm::Support::Render.render(template_content, locals)
      end

      def templates_path
        Pathname.new(File.join(File.dirname(__FILE__), "..", "templates/init"))
      end
    end
  end
end
