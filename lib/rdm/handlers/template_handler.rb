require 'pathname'
require 'fileutils'

module Rdm
  module Handlers
    class TemplateHandler
      class << self
        def generate(template_name:, local_path:, current_path:, locals: {}, ignore_source_file: false)
          Rdm::Handlers::TemplateHandler.new(
            template_name:      template_name.to_s, 
            local_path:         local_path, 
            current_path:       current_path, 
            ignore_source_file: ignore_source_file,
            locals:             locals
          ).generate
        end
      end

      def initialize(template_name:, local_path:, current_path:, locals:, ignore_source_file:)
        @template_name      = template_name
        @local_path         = local_path
        @current_path       = current_path
        @ignore_source_file = ignore_source_file
        @missing_variables  = []
        
        @locals            = default_locals.merge(locals)
      end

      def generate
        project_path      = @ignore_source_file ? @current_path : File.dirname(Rdm::SourceLocator.locate(@current_path))
        template_detector = Rdm::Templates::TemplateDetector.new(project_path)

        @template_directory    = template_detector.detect_template_folder(@template_name)
        @destination_directory = File.join(project_path, @local_path)

        template_files_list = Dir[ 
          File.join(@template_directory, '**', '.?*'), 
          File.join(@template_directory, '**', '*') 
        ]
        .select { |p| File.file?(p) }
        .reject { |p| File.basename(p) == '.DS_Store' }

        template_dir_list   = Dir[ File.join(@template_directory, '**', '*') ].select { |p| File.directory? p }

        template_files_list.each do |file|
          missings = Rdm::Templates::TemplateRenderer.get_undefined_variables(get_destination_path(file), @locals)
          
          if File.extname(file) != '.erb'
            missings.push(
              *Rdm::Templates::TemplateRenderer.get_undefined_variables(File.read(file), @locals)
            ) 
          end
          
          @missing_variables.push(*missings)
        end

        template_dir_list.each do |dir|
          @missing_variables.push(
            *Rdm::Templates::TemplateRenderer.get_undefined_variables(get_destination_path(dir), @locals)
          )
        end

        @missing_variables.uniq!
        if @missing_variables.any?
          puts "Undefined variables were found:"
          @missing_variables.size.times {|t| puts "  #{t+1}. #{@missing_variables[t]}"}
          puts

          @missing_variables.each do |var|
            print "Type value for '#{var}': "
            @locals[var] = STDIN.gets.chomp
          end
        end

        template_dir_list.each do |dir|
          rendered_abs_path = Rdm::Templates::TemplateRenderer.handle(get_destination_path(dir), @locals)
          FileUtils.mkdir_p rendered_abs_path
        end

        template_files_list.map do |file|
          rendered_abs_path = Rdm::Templates::TemplateRenderer.handle(get_destination_path(file), @locals)
          raise Rdm::Errors::TemplateFileExists.new(rendered_abs_path) if File.exists?(rendered_abs_path)

          rendered_file_content = File.extname(file) == '.erb' ?
            File.read(file) :
            Rdm::Templates::TemplateRenderer.handle(File.read(file), @locals)
            
          FileUtils.mkdir_p(File.dirname(rendered_abs_path))
          File.open(rendered_abs_path, 'w') { |f| f.write rendered_file_content }

          Pathname.new(rendered_abs_path).relative_path_from Pathname.new(project_path)
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