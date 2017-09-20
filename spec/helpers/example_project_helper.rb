require "fileutils"
require "pathname"

module ExampleProjectHelper
  RDM_EXAMPLE_PROJECT_PATH = File.expand_path(File.join(__dir__, '../../example'))

  INIT_TEMPLATES_PATH     = File.expand_path(File.join(__dir__, '../../lib/rdm/templates/init'))
  INIT_GENERATED_FILES    = Dir[File.join(INIT_TEMPLATES_PATH, '**/*')]

  attr_reader :example_project_path, :rdm_source_file

  def reset_example_project
    FileUtils.rm_rf(@example_project_path)
  end

  def initialize_example_project(path: '/tmp/example', skip_rdm_init: false)
    @example_project_path = path
    @rdm_source_file = File.join(@example_project_path, Rdm::SOURCE_FILENAME)

    FileUtils.cp_r(RDM_EXAMPLE_PROJECT_PATH, @example_project_path)

    if skip_rdm_init
      INIT_GENERATED_FILES.each do |f|
        rel_path = Pathname.new(f).relative_path_from(Pathname.new(INIT_TEMPLATES_PATH))

        FileUtils.rm_rf(File.join(@example_project_path, rel_path))
      end
      
      FileUtils.rm_rf(File.join(@example_project_path, '.rdm'))
    end
  end
end