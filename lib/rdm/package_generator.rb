require 'fileutils'

class Rdm::PackageGenerator
  class << self
    def generate_package(current_dir, package_name, package_relative_path, skip_rspec = false)
      source_path = File.join(current_dir, Rdm::SOURCE_FILENAME)
      source_content = File.open(source_path).read

      rdm_source          = Rdm::SourceParser.parse(source_content)
      package_subdir_name = Rdm.settings.send(:package_subdir_name)

      if Dir.exist?(File.join(current_dir, package_relative_path))
        raise Rdm::Errors::PackageDirExists, "package dir exists"
      end

      if rdm_source.package_paths.include?(package_relative_path)
        raise Rdm::Errors::PackageExists, "package exists"
      end

      FileUtils.mkdir_p(File.join(current_dir, package_relative_path, package_subdir_name, package_name))
      FileUtils.touch(File.join(current_dir, package_relative_path, package_subdir_name, "#{package_name}.rb"))
      FileUtils.touch(File.join(current_dir, package_relative_path, '.gitignore'))

      if !skip_rspec
        FileUtils.cd(File.join(current_dir, package_relative_path, package_subdir_name)) do
          system('rspec --init')
        end
      end

      package_rb_template = <<EOF
package do
  name    "#{package_name}"
  version "1.0.0"
end

dependency do
  # TODO: add dependencies here
end
EOF
      File.write(File.join(current_dir, package_relative_path, 'Package.rb'), package_rb_template)

      source_content += "\npackage '#{package_relative_path}'"
      File.write(source_path, source_content)
    end
  end
end
