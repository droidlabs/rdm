module Rdm
  module CLI
    class Init
      class << self
        def run(opts={})
          Rdm::CLI::Init.new(opts).run
        end
      end

      attr_accessor :current_dir, :test, :console
      def initialize(current_dir:, test:, console:)
        @current_dir = current_dir
        @test        = test
        @console     = console
      end

      def run
        check_preconditions!
        begin
          generate
        rescue Errno::ENOENT => e
          puts "Error occurred. Possible reasons:\n #{current_dir} not found. Please run on empty directory \n#{e.inspect}"
        rescue Rdm::Errors::ProjectAlreadyInitialized
          puts "Error. Project was already initialized."
        end
      end


      def generate
        Rdm::Gen::Init.generate(
          current_dir: current_dir,
          test:        test,
          console:     console,
        )
      end

      def check_preconditions!
        if  current_dir.empty?
          puts 'Current directory was not specified!'
          exit 1
        end
      end
    end
  end
end
