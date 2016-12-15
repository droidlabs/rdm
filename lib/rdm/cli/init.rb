module Rdm
  module CLI
    class Init
      class << self
        def run(opts={})
          Rdm::CLI::Init.new(opts).run
        end
      end

      attr_accessor :test, :console
      def initialize(test:, console:)
        @test    = test
        @console = console
      end

      def run
        puts "running... with #{self.inspect}"
      end
    end
  end
end
