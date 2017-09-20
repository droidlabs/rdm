require 'fileutils'
require 'pathname'

module Rdm
  module Gen
    class Init
      TEMPLATE_NAME        = 'init'
      INIT_PATH            = './'
      LOCAL_TEMPLATES_PATH = '.rdm/templates'

      class << self
        def generate(current_path:, test: 'rspec', console: 'irb', stdout: STDOUT)
          Rdm::Gen::Init.new(current_path, test, console, stdout).generate
        end
      end

      def initialize(current_path, test, console, stdout)
        @current_path      = current_path
        @test              = test
        @console           = console
        @template_detector = Rdm::Templates::TemplateDetector.new(current_path)
        @stdout            = stdout
      end

      def generate
        if @current_path.nil? || @current_path.empty?
          raise Rdm::Errors::InvalidParams, "Error. Project folder not specified. Type path to rdm project, ex: 'rdm init .'" 
        end
        raise Rdm::Errors::InvalidProjectDir, @current_path unless Dir.exist?(@current_path)

        if File.exist?(File.join(@current_path, Rdm::SOURCE_FILENAME))
          raise Rdm::Errors::ProjectAlreadyInitialized, "#{@current_path} has already #{Rdm::SOURCE_FILENAME}"
        end
        
        generated_files = Rdm::Handlers::TemplateHandler.generate(
          template_name:      TEMPLATE_NAME,
          current_path:       @current_path,
          local_path:         INIT_PATH,
          ignore_source_file: true,
          stdout:             @stdout
        )

        FileUtils.mkdir_p(local_templates_path)
        FileUtils.cp_r(
          @template_detector.gem_template_folder('package'),
          File.dirname(@template_detector.project_template_folder('package'))
        )
        FileUtils.cp_r(
          @template_detector.gem_template_folder('configs'),
          File.dirname(@template_detector.project_template_folder('configs'))
        )

        generated_files
      end

      private

      def local_templates_path
        File.join(@current_path, LOCAL_TEMPLATES_PATH)
      end
    end
  end
end
