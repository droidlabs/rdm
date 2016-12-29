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
        Rdm::SourceInstaller.install(source_path)
      rescue Rdm::Errors::SourceFileDoesNotExist => e
        puts "*** #{path} does not include any #{Rdm::SOURCE_FILENAME} in its tree hierarchy!"
      end
    end

    def source_path
      Rdm::SourceLocator.locate(path)
    end
  end
end
