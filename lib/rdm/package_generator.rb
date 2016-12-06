require 'fileutils'

class Rdm::PackageGenerator
  class << self
    def generate_package(current_dir, package_name, package_relative_path, skip_rspec = false)
      Rdm::PackageGenerator.new(
        current_dir, package_name, package_relative_path, skip_rspec
      ).create
    end
  end

  attr_accessor :current_dir, :package_name, :package_relative_path, :skip_rspec
  def initialize(current_dir, package_name, package_relative_path, skip_rspec = false)
    @current_dir           = current_dir
    @package_name          = package_name
    @package_relative_path = package_relative_path
    @skip_rspec            = skip_rspec
  end

  def rdm_source
    @rdm_source ||= Rdm::SourceParser.parse(source_content)
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
      FileUtils.mkdir_p(File.join(package_relative_path, package_subdir_name, package_name))
      FileUtils.touch(File.join(package_relative_path, package_subdir_name, "#{package_name}.rb"))
      FileUtils.touch(File.join(package_relative_path, '.gitignore'))

      if !skip_rspec
        init_rspec
      end

      File.write(File.join(package_relative_path, 'Package.rb'), package_rb_template)
    end
    move_templates
    new_source_content = source_content + "\npackage '#{package_relative_path}'"
    File.write(source_path, new_source_content)
  end

  def init_rspec
    FileUtils.cd(File.join(package_relative_path)) do
      system('rspec --init')
    end
  end

  def move_templates
    Dir.chdir(File.join(File.dirname(__FILE__), "templates")) do
      copy_template(".rspec")
      copy_template(".gitignore")
      copy_template("rspec/spec_helper.rb")
    end
  end

  def copy_template(filepath)
    from = filepath
    to   = File.join(current_dir, package_relative_path, filepath)
    FileUtils.mkdir_p(File.dirname(to))
    FileUtils.cp(from, to)
  end

  def check_preconditions!
    if Dir.exist?(File.join(current_dir, package_relative_path))
      raise Rdm::Errors::PackageDirExists, "package dir exists"
    end

    if rdm_source.package_paths.include?(package_relative_path)
      raise Rdm::Errors::PackageExists, "package exists"
    end
  end

  def package_rb_template
v = <<EOF
package do
  name    '#{package_name}'
  version '1.0.0'
end

dependency do
  # import 'utils'
end
EOF
  end
end
