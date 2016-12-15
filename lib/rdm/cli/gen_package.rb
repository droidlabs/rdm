module Rdm
  module CLI
    class GenPackage
      class << self
        def run(opts={})
          Rdm::CLI::GenPackage.new(opts).run
        end
      end

      attr_accessor :package_name, :current_dir,  :package_relative_path, :skip_tests
      def initialize(package_name:, current_dir:, path:, skip_tests:)
        @current_dir           = current_dir
        @package_name          = package_name
        @package_relative_path = path
        @skip_tests            = skip_tests
      end

      def run
        puts "running... with #{self.inspect}"
      end
    end
  end
end
