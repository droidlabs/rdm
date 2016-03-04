class Rdm::SourceParser
  class << self
    # Parse source file and return Source object
    # @param source_content [String] Source file content
    # @return [Rdm::Source] Source
    def parse(source_content)
      source = Rdm::Source.new
      source.instance_eval(source_content)
      source
    end
  end
end