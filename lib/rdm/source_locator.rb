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
      raise Rdm::Errors::SourceFileDoesNotExist.new(path) if some_path == "/"
      if is_present?(some_path)
        return potential_file(some_path)
      else
        find_source_path_in_hierarchy(File.dirname(some_path))
      end
    end

    def is_present?(some_path)
      File.exists?(potential_file(some_path))
    end

    def potential_file(some_path)
      File.join(some_path, Rdm::SOURCE_FILENAME)
    end
  end
end
