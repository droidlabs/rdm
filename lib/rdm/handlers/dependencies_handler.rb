module Rdm
  module Handlers
    class DependenciesHandler
      class << self
        def show_names(package_name:, project_path:)
          new(package_name, project_path).show_names
        end

        def show_packages(package_name:, project_path:)
          new(package_name, project_path).show_packages
        end
      end
      
      def initialize(package_name, project_path)
        @package_name = package_name
        @project_path = project_path
      end

      def show_names
        if @package_name.nil? || @package_name.empty?
          raise Rdm::Errors::InvalidParams, "Package name should be specified" 
        end
        
        if @project_path.nil? || @project_path.empty?
          raise Rdm::Errors::InvalidParams, "Project directory should be specified" 
        end
        
        recursive_find_dependencies([@package_name])
      end

      def show_packages
        names = show_names

        source.packages.values.select do |p| 
          names.include?(p.name)
        end
      end

      private

      def recursive_find_dependencies(package_names)
        all_packages = source.packages.values

        deps_package_names = all_packages
          .select {|pkg| package_names.include?(pkg.name)}
          .map(&:local_dependencies)
          .flatten
          .uniq

        extended_package_names = deps_package_names | package_names
        
        return package_names if package_names == extended_package_names
        
        recursive_find_dependencies(extended_package_names)
      end

      def source
        @source ||= Rdm::SourceParser.read_and_init_source(File.join(@project_path, Rdm::SOURCE_FILENAME))
      end
    end
  end
end