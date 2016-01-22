class Rdm::SourceParser
  class Scope
    attr_accessor :package_paths

    def package(package_path)
      self.package_paths ||= []
      self.package_paths << package_path
    end
  end

  class << self
    # Parse source file and return package paths
    def parse(source_content)
      scope = Scope.new
      scope.instance_eval(source_content)
      scope.package_paths
    end
  end
end