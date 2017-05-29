require 'fileutils'
require 'pathname'
require 'active_support/inflector'

module Rdm
  module Gen
    class Init
      class << self
        def generate(current_dir:, test: 'rspec', console: 'irb')
          Rdm::Gen::Init.new(current_dir: current_dir, test: test, console: console).generate
        end
      end

      include Rdm::Gen::Concerns::TemplateHandling

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
            ['Rdm.packages'],
            template_content('Rdm.packages.erb')
          )

          ensure_file(
            ['Gemfile'],
            template_content('Gemfile.erb')
          )

          ensure_file(
            ['Readme.md'],
            template_content('Readme.md.erb')
          )

          FileUtils.mkdir_p project_templates_path(current_dir)
          FileUtils.copy_entry package_templates_path.to_s, project_templates_path(current_dir)
          
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
          copy_template('tests/run')
        end
      end

      private
      def templates_path(filename = nil)
        Pathname.new(File.join(File.dirname(__FILE__), '..', 'templates/init'))
      end
      alias get_templates_directory templates_path

      def package_templates_path
        Pathname.new(File.join(File.dirname(__FILE__), '..', 'templates/package'))
      end

      def project_templates_path(project_path)
        File.join(project_path, ".rdm", "package_templates")
      end

      def target_path
        current_dir
      end
    end
  end
end
