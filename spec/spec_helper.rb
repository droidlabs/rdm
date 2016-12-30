require 'rdm'
require "byebug"

Rdm.setup do
  silence_missing_package_file(true)
end

RSpec.configure do |config|
  config.color = true
end


module SetupHelper
  def clean_tmp
    FileUtils.rm_rf(tmp_dir)
  end

  def fresh_project
    clean_tmp
    FileUtils.mkdir_p(tmp_dir)
    FileUtils.cp_r(example_src, tmp_dir)
  end

  def fresh_empty_project
    clean_tmp
    FileUtils.mkdir_p(empty_project_dir)
  end

  def project_dir
    File.join(tmp_dir, "example")
  end

  def empty_project_dir
    File.join(tmp_dir, "empty_project")
  end

  def tmp_dir
    File.join(File.dirname(__FILE__), "tmp/projects")
  end

  def example_src
    File.join(File.dirname(__FILE__), "../example/")
  end
end
