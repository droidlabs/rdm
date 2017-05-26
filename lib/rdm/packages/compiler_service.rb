require 'fileutils'

module Rdm
  module Packages
    class CompilerService
      class << self
        def compile(compile_path:, project_path:, package_name:)
          Rdm::Packages::CompilerService.new(
            compile_path: compile_path,
            project_path: project_path,
            package_name: package_name
          ).compile
        end
      end

      def initialize(compile_path:, project_path:, package_name:)
        @compile_path = compile_path
        @project_path = project_path
        @package_name = package_name
      end

      def compile
        @source = Rdm::SourceParser.read_and_init_source(File.join(@project_path, Rdm::SOURCE_FILENAME))

        reset_directory!(@compile_path)

        dependent_package_names = recursive_find_dependencies([@package_name])
        dependent_packages      = @source.packages.values.select do |p| 
          dependent_package_names.include?(p.name)
        end

        dependent_packages.each do |pkg|
          rel_path = Pathname.new(pkg.path).relative_path_from(Pathname.new(@project_path))
          new_path = File.dirname(File.join(@compile_path, rel_path))
          
          FileUtils.mkdir_p(new_path)
          FileUtils.cp_r(pkg.path, new_path)
        end

        
        source_rdm_path = File.join(@project_path, Rdm::SOURCE_FILENAME)
        dest_rdm_path   = File.join(@compile_path, Rdm::SOURCE_FILENAME)
        package_definition_regex = /package\s+['"]([\w\/]+)['"]/i

        File.open(dest_rdm_path, "w") do |out_file|
          File.foreach(source_rdm_path) do |line|
            package_line = package_definition_regex.match(line)
            if package_line.nil?
              out_file.puts line
            else
              dependent_package_definition = dependent_packages.detect do |pkg|
                package_line[1] == Pathname.new(pkg.path).relative_path_from(Pathname.new(@project_path)).to_s
              end

              out_file.puts line if dependent_package_definition.present?
            end
          end
        end

        FileUtils.cp_r(File.join(@project_path, 'configs'), File.join(@compile_path, 'configs'))

        Rdm.settings.compile_ignore_files.each do |file|
          Dir["#{@compile_path}/**/#{file}"].each do |file_to_remove|
            FileUtils.rm_rf(file_to_remove)
          end
        end

        Rdm.settings.compile_add_files.each do |file|
          FileUtils.cp(File.join(@project_path, file), File.join(@compile_path, file))
        end

        return dependent_package_names
      end

      private
        def reset_directory!(dir)
          FileUtils.rm_rf(dir) if Dir.exists?(dir)
          FileUtils.mkdir_p(dir)

          nil
        end

        def recursive_find_dependencies(package_names)
          all_packages = @source.packages.values

          deps_package_names = all_packages
            .select {|pkg| package_names.include?(pkg.name)}
            .map(&:local_dependencies)
            .flatten
            .uniq

          extended_package_names = deps_package_names | package_names
          
          return package_names if package_names == extended_package_names
          
          recursive_find_dependencies(extended_package_names)
        end
    end
  end
end