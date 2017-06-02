require 'pathname'
require 'fileutils'

module Rdm
  module Handlers
    class TemplateHandler
      class << self
        def generate(template_name:, local_path:, current_path:, locals: {}, ask_undef_action: nil)
          ask_undef_action ||= -> () { STDIN.gets.chomp }
          template_name      = template_name.to_s

          Rdm::Handlers::TemplateHandler.new(
            template_name:    template_name, 
            local_path:       local_path, 
            current_path:     current_path, 
            locals:           locals,
            ask_undef_action: ask_undef_action
          ).generate
        end
      end

      def initialize(template_name:, local_path:, current_path:, locals:, ask_undef_action:)
        @template_name     = template_name
        @local_path        = local_path
        @current_path      = current_path
        @ask_undef_action  = ask_undef_action
        @missing_variables = []
        
        @locals            = default_locals.merge(locals)
      end

      def generate
        project_path      = File.dirname(Rdm::SourceLocator.locate(@current_path))
        template_detector = Rdm::Templates::TemplateDetector.new(project_path)

        @template_directory    = template_detector.detect_template_folder(@template_name)
        @destination_directory = File.join(project_path, @local_path, @template_name)

        template_files_list = Dir[ File.join(@template_directory, '**', '*') ].reject { |p| File.directory? p }

        template_files_list.each do |file|
          missings = Rdm::Templates::TemplateRenderer.get_undefined_variables(get_destination_path(file), @locals)
          
          if File.extname(file) != '.erb'
            missings.push(
              *Rdm::Templates::TemplateRenderer
                .get_undefined_variables(File.read(file), @locals)
            ) 
          end
          
          @missing_variables.push(*missings)
        end
        
        @missing_variables.uniq!
        if @missing_variables.any?
          puts "#{@missing_variables.size} undefined variables were found."
          @missing_variables.size.times {|t| puts "#{t+1}. #{@missing_variables[t]}"}

          @missing_variables.each do |var|
            puts "Type value for '#{var}':"
            @locals[var] = @ask_undef_action.call
          end
        end

        template_files_list.each do |file|
          rendered_abs_path = Rdm::Templates::TemplateRenderer.handle(get_destination_path(file), @locals)
          raise Rdm::Errors::TemplateFileExists.new(rendered_abs_path) if File.exists?(rendered_abs_path)

          rendered_file_content = File.extname(file) == '.erb' ?
            File.read(file) :
            Rdm::Templates::TemplateRenderer.handle(File.read(file), @locals)
            
          FileUtils.mkdir_p(File.dirname(rendered_abs_path))
          File.open(rendered_abs_path, 'w') { |f| f.write rendered_file_content }
        end
      end

      private

      def get_destination_path(file)
        return nil unless defined? @template_directory && defined? @destination_directory

        template_rel_path = Pathname.new(file).relative_path_from Pathname.new(@template_directory)
        File.join(@destination_directory, template_rel_path)
      end   

      def default_locals
        {
          package_subdir_name: Rdm.settings.send(:package_subdir_name)
        }
      end
    end
  end
end