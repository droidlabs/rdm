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
        check_preconditions!
        begin
          generate
        rescue Errno::ENOENT => e
          puts "Error occurred. Possible reasons:\n #{Rdm::SOURCE_FILENAME} not found. Please run on directory containing #{Rdm::SOURCE_FILENAME} \n#{e.inspect}"
        rescue Rdm::Errors::PackageExists
          puts "Error. Package already exist. Package was not generated"
        rescue Rdm::Errors::PackageDirExists
          puts "Error. Directory #{package_relative_path} exists. Package was not generated"
        end
      end

      def generate
        Rdm::PackageGenerator.generate_package(
          self.current_dir,
          self.package_name,
          self.package_relative_path,
          self.skip_tests
        )
      end

      def check_preconditions!
        if package_name.empty?
          puts 'Package name was not specified!'
          exit 1
        end
      end
    end
  end
end
