require 'fileutils'
require 'pathname'
require "active_support/inflector"


# http://stackoverflow.com/questions/8954706/render-an-erb-template-with-values-from-a-hash
require 'erb'
require 'ostruct'
class ErbalT < OpenStruct
  def self.render(template, locals)
    self.new(locals).render(template)
  end
  def render(template)
    ERB.new(template).result(binding)
  end
end


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
      ensure_file([package_relative_path, '.gitignore'])
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
    end
    move_templates
    new_source_content = source_content + "\npackage '#{package_relative_path}'"
    File.write(source_path, new_source_content)
  end

  def ensure_file(path_array, content="")
    filename = File.join(*path_array)
    FileUtils.mkdir_p(File.dirname(filename))
    File.write(filename, content)
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
      copy_template("spec/spec_helper.rb")
    end
  end

  def copy_template(filepath)
    from = filepath
    to   = File.join(current_dir, package_relative_path, filepath)
    FileUtils.mkdir_p(File.dirname(to))
    # copy_entry(src, dest, preserve = false, dereference_root = false, remove_destination = false)
    FileUtils.copy_entry(from, to, false, false, true)
  end

  def template_content(file, locals={})
    template_path    = Pathname.new(File.join(File.dirname(__FILE__), "templates")).join(file)
    template_content = File.read(template_path)
    ErbalT.render(template_content, locals)
  end

  def check_preconditions!
    if Dir.exist?(File.join(current_dir, package_relative_path))
      raise Rdm::Errors::PackageDirExists, "package dir exists"
    end

    if rdm_source.package_paths.include?(package_relative_path)
      raise Rdm::Errors::PackageExists, "package exists"
    end
  end
end
