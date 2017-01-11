module Rdm
  class SourceLocator
    def self.locate(path)
      Rdm::SourceLocator.new(path).locate
    end

    attr_accessor :path
    def initialize(path)
      @path = path
    end

    def locate
      find_source_path_in_hierarchy(path)
    end

    def find_source_path_in_hierarchy(some_path)
      some_path = File.expand_path(some_path)
      raise Rdm::Errors::SourceFileDoesNotExist, path if some_path == '/'
      return potential_file(some_path) if present?(some_path)
      find_source_path_in_hierarchy(File.dirname(some_path))
    end

    def present?(some_path)
      File.exist?(potential_file(some_path))
    end

    def potential_file(some_path)
      File.join(some_path, Rdm::SOURCE_FILENAME)
    end
  end
end
