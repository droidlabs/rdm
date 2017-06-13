module Rdm
  module Handlers
    class DependenciesHandler
      ALREADY_MENTIONED_DEPS = '...'
      
      class << self
        def show_names(package_name:, project_path:)
          new(package_name, project_path).show_names
        end

        def show_packages(package_name:, project_path:)
          new(package_name, project_path).show_packages
        end
        
        def draw(package_name:, project_path:)
          new(package_name, project_path).draw
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

      
      def draw(pkg_name = @package_name, uniq_packages = [], self_predicate = '', child_predicate = '')
        raise Rdm::Errors::PackageHasNoDependencies, @package_name if source.packages[@package_name].local_dependencies.empty?
        
        node = [format(pkg_name, self_predicate)]
        
        return node if pkg_name == ALREADY_MENTIONED_DEPS

        local_dependencies = source.packages[pkg_name].local_dependencies.dup

        if uniq_packages.include?(pkg_name)
          local_dependencies = local_dependencies.count == 0 ? [] : [ALREADY_MENTIONED_DEPS]
        else
          uniq_packages.push(pkg_name)
        end

        local_dependencies.count.times do
          dependency = local_dependencies.pop

          if local_dependencies.empty?
            tmp_self_predicate = child_predicate + '2'
            tmp_child_predicate = child_predicate + '0'
          else
            tmp_self_predicate = child_predicate + '1'
            tmp_child_predicate = child_predicate + '3'
          end
          
          node.push(*draw(dependency, uniq_packages, tmp_self_predicate, tmp_child_predicate))
        end

        node
      end

      private

      def source
        @source ||= Rdm::SourceParser.read_and_init_source(Rdm::SourceLocator.locate(@project_path))
      end

      def format(pkg_name, predicate)
        predicate
          .concat(pkg_name)
          .gsub(/0/, '    ')
          .gsub(/1/, '├── ')
          .gsub(/2/, '└── ')
          .gsub(/3/, '|   ')
      end

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
    end
  end
end