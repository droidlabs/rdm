require 'fileutils'
require 'pathname'
require "active_support/inflector"


module Rdm
  module Gen
    class Package
      class << self
        def generate_package(current_dir:, package_name:, package_relative_path:, skip_rspec: false)
          Rdm::Gen::Package.new(
            current_dir, package_name, package_relative_path, skip_rspec
          ).create
        end
      end

      attr_accessor :current_dir, :package_name, :package_relative_path, :skip_rspec
      def initialize(current_dir, package_name, package_relative_path, skip_rspec = false)
        @current_dir           = File.expand_path(current_dir)
        @package_name          = package_name
        @package_relative_path = package_relative_path
        @skip_rspec            = skip_rspec
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
            template_content("main_module_file.rb.erb", {package_name_camelized: package_name.camelize})
          )
          ensure_file(
            [package_relative_path, 'Package.rb'],
            template_content("package.rb.erb", {package_name: package_name})
          )
          if !skip_rspec
            init_rspec
          end

          move_templates
          append_package_to_rdm_packages
        end
      end

      def check_preconditions!
        if Dir.exist?(File.join(current_dir, package_relative_path))
          raise Rdm::Errors::PackageDirExists, "package dir exists"
        end

        if rdm_source.package_paths.include?(package_relative_path)
          raise Rdm::Errors::PackageExists, "package exists"
        end
      end

      def append_package_to_rdm_packages
        new_source_content = source_content + "\npackage '#{package_relative_path}'"
        File.write(source_path, new_source_content)
      end

      def init_rspec
        FileUtils.cd(File.join(package_relative_path)) do
          system('rspec --init')
        end
      end

      def move_templates
        Dir.chdir(templates_path) do
          copy_template(".rspec")
          copy_template(".gitignore")
          copy_template("spec/spec_helper.rb")
          copy_template("bin/console_irb", "bin/console")
        end
      end

    private
      def ensure_file(path_array, content="")
        filename = File.join(*path_array)
        FileUtils.mkdir_p(File.dirname(filename))
        File.write(filename, content)
      end

      def copy_template(filepath, target_name=nil)
        from          = filepath
        target_name ||= filepath
        to            = File.join(current_dir, package_relative_path, target_name)
        FileUtils.mkdir_p(File.dirname(to))
        # copy_entry(src, dest, preserve = false, dereference_root = false, remove_destination = false)
        FileUtils.copy_entry(from, to, true, false, true)
      end

      def template_content(file, locals={})
        template_path    = templates_path.join(file)
        template_content = File.read(template_path)
        Rdm::Support::Render.render(template_content, locals)
      end

      def templates_path
        Pathname.new(File.join(File.dirname(__FILE__), "..", "templates"))
      end
    end
  end
end
