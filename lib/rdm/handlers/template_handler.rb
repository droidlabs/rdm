require 'pathname'
require 'fileutils'

module Rdm
  module Handlers
    class TemplateHandler
      REJECTED_TEMPLATE_FILES   = %W(.DS_Store)
      NOT_HANDLED_TEMPLATES_EXT = %W(.erb)

      class << self
        def generate(template_name:, local_path:, current_path:, locals: {}, 
                     ignore_source_file: false, stdout: STDOUT, stdin: STDIN)

          Rdm::Handlers::TemplateHandler.new(
            template_name:      template_name.to_s, 
            local_path:         local_path, 
            current_path:       current_path, 
            ignore_source_file: ignore_source_file,
            locals:             locals,
            stdout:             stdout,
            stdin:              stdin
          ).generate
        end
      end

      def initialize(template_name:, local_path:, current_path:,  
                     locals:, ignore_source_file:, stdout:, stdin:)

        @template_name      = template_name
        @local_path         = local_path
        @current_path       = current_path
        @ignore_source_file = ignore_source_file
        @missing_variables  = []
        @stdout             = stdout
        @stdin              = stdin

        default_locals     = { package_subdir_name: Rdm.settings.send(:package_subdir_name) }
        @locals            = default_locals.merge(locals)
      end

      def generate
        project_path      = @ignore_source_file ? @current_path : File.dirname(Rdm::SourceLocator.locate(@current_path))
        template_detector = Rdm::Templates::TemplateDetector.new(project_path)

        render_helper_path = "#{project_path}/.rdm/helpers/render_helper.rb"
        require_relative render_helper_path if File.exist?(render_helper_path)

        @template_directory    = template_detector.detect_template_folder(@template_name)
        @destination_directory = File.join(project_path, @local_path)

        template_files_list = Dir
          .glob(File.join(@template_directory, '**', '*'), File::FNM_DOTMATCH)
          .reject { |path| REJECTED_TEMPLATE_FILES.include? File.basename(path)  }

        template_files_list.each do |path|
          @missing_variables.concat(
            Rdm::Templates::TemplateRenderer.get_undefined_variables(get_destination_path(path), @locals)
          ) 

          if handle_file_content?(path)
            @missing_variables.concat(
              Rdm::Templates::TemplateRenderer.get_undefined_variables(File.read(path), @locals)
            ) 
          end
        end

        if @missing_variables.any?
          @missing_variables.uniq!

          @stdout.puts "Undefined variables were found:"
          @missing_variables.size.times {|t| @stdout.puts "  #{t+1}. #{@missing_variables[t]}"}

          @missing_variables.each do |var|
            @stdout.print "Type value for '#{var}': "
            @locals[var] = @stdin.gets.chomp
          end
        end

        template_files_list.map! do |path|
          rendered_abs_path = Rdm::Templates::TemplateRenderer.handle(get_destination_path(path), @locals)
          rendered_rel_path = Pathname.new(rendered_abs_path).relative_path_from Pathname.new(project_path)

          if File.file?(rendered_abs_path) && File.exists?(rendered_abs_path)
            @stdout.puts "Warning! #{rendered_rel_path} already exists. Skipping file creation..."
            next
          end

          if File.directory?(path)
            FileUtils.mkdir_p rendered_abs_path
            next
          end

          rendered_file_content = handle_file_content?(path) ?
            Rdm::Templates::TemplateRenderer.handle(File.read(path), @locals) :
            File.read(path)
            
          FileUtils.mkdir_p(File.dirname(rendered_abs_path))
          File.open(rendered_abs_path, 'w') { |f| f.write rendered_file_content }

          rendered_rel_path
        end

        template_files_list.compact
      end

      private

      def get_destination_path(file)
        return nil unless defined? @template_directory && defined? @destination_directory

        template_rel_path = Pathname.new(file).relative_path_from Pathname.new(@template_directory)
        File.join(@destination_directory, template_rel_path)
      end   

      def handle_file_content?(path)
        File.file?(path) && !NOT_HANDLED_TEMPLATES_EXT.include?(File.extname(path))
      end
    end
  end
end