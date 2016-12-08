module Rdm
  class AutoUpdater
    class << self
      def update(path)
        Rdm::AutoUpdater.new(path).update
      end
    end

    attr_accessor :path
    def initialize(path)
      @path = path
    end

    def update
      begin
        source_path = find_source_path_in_hierarchy(path)
        Rdm::SourceInstaller.install(source_path)
      rescue Rdm::Errors::SourceFileDoesNotExist => e
        puts "*** #{path} does not include any #{Rdm::SOURCE_FILENAME} in its tree hierarchy!"
      end
    end

    def find_source_path_in_hierarchy(some_path)
      some_path = File.expand_path(some_path)
      raise SourceFileDoesNotExist if some_path == "/"
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
