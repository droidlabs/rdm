module Rdm
  module CLI
    class Init
      class << self
        def run(current_path:, test:, console:, stdout: $stdout)
          Rdm::CLI::Init.new(current_path, test, console, stdout).run
        end
      end

      def initialize(current_path, test, console, stdout)
        @current_path = current_path
        @test         = test
        @console      = console
        @stdout       = stdout
      end

      def run
        generated_files_list = Rdm::Gen::Init.generate(
          current_path: @current_path,
          test:         @test,
          console:      @console
        )

        generated_files_list.each { |file| @stdout.puts "Generated: #{file}" }
      rescue Errno::ENOENT => e
        @stdout.puts "Error occurred. Possible reasons:\n #{@current_path} not found. Please run on empty directory \n#{e.inspect}"
      rescue Rdm::Errors::ProjectAlreadyInitialized
        @stdout.puts 'Error. Project was already initialized'
      rescue Rdm::Errors::InvalidParams => e
        @stdout.puts e.message
      rescue Rdm::Errors::InvalidProjectDir => e
        @stdout.puts "#{e.message} doesn't exist. Initialize new rdm project with existing directory"
      end
    end
  end
end
