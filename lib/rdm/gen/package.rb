require 'fileutils'
require 'pathname'
require 'active_support/inflector'

module Rdm
  module Gen
    class Package
      class << self
        def generate(current_dir:, package_name:, package_relative_path:, skip_tests: false)
          Rdm::Gen::Package.new(
            current_dir, package_name, package_relative_path, skip_tests
          ).create
        end
      end

      include Rdm::Gen::Concerns::TemplateHandling

      attr_accessor :current_dir, :package_name, :package_relative_path, :skip_tests
      def initialize(current_dir, package_name, package_relative_path, skip_tests = false)
        @current_dir           = File.expand_path(current_dir)
        @package_name          = package_name
        @package_relative_path = package_relative_path
        @skip_tests            = skip_tests
      end

      def rdm_source
        @rdm_source ||= Rdm::SourceParser.new(source_path).parse_source_content
      end

      def source_path
        File.join(current_dir, Rdm::SOURCE_FILENAME)
      end

      def source_content
        File.open(source_path).read
      end

      def create
        check_preconditions!
        package_subdir_name = Rdm.settings.send(:package_subdir_name)

        Dir.chdir(current_dir) do
          ensure_file([package_relative_path, '.gitignore'])
          ensure_file([package_relative_path, package_subdir_name, package_name, '.gitignore'])
          ensure_file(
            [package_relative_path, package_subdir_name, "#{package_name}.rb"],
            template_content('main_module_file.rb.erb', package_name_camelized: package_name.camelize)
          )
          ensure_file(
            [package_relative_path, 'Package.rb'],
            template_content('package.rb.erb', package_name: package_name)
          )
          init_rspec unless skip_tests

          move_templates
          append_package_to_rdm_packages
        end
      end

      def check_preconditions!
        if Dir.exist?(File.join(current_dir, package_relative_path))
          raise Rdm::Errors::PackageDirExists, 'package dir exists'
        end

        if rdm_source.package_paths.include?(package_relative_path)
          raise Rdm::Errors::PackageExists, 'package exists'
        end
      end

      def append_package_to_rdm_packages
        new_source_content = source_content.strip + "\npackage '#{package_relative_path}'"
        File.write(source_path, new_source_content)
      end

      def init_rspec
        Dir.chdir(get_templates_directory('.rspec')) { copy_template('.rspec') }
        Dir.chdir(get_templates_directory('spec/spec_helper.rb')) { copy_template('spec/spec_helper.rb') }
      end

      def move_templates
        Dir.chdir(get_templates_directory('bin/console_irb')) { copy_template('bin/console_irb', 'bin/console') }
      end

      private

      def get_templates_directory(file_name = nil)
        return templates_path unless file_name

        directory = [local_templates_path, templates_path].detect do |dir| 
          File.exists?(File.join(dir, file_name))
        end
      end

      def templates_path
        Pathname.new(File.join(File.dirname(__FILE__), '..', 'templates/package'))
      end

      def local_templates_path
        Pathname.new(File.join(current_dir, ".rdm/package_templates"))
      end

      def target_path
        File.join(current_dir, package_relative_path)
      end
    end
  end
end
