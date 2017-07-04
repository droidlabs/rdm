class Rdm::SpecRunner::Runner
  attr_accessor :skipped_packages
  attr_accessor :prepared_command_params
  attr_accessor :command
  def initialize(package: nil, spec_matcher: nil, path: nil)
    @package          = package,
    @spec_matcher     = spec_matcher.to_s
    @skipped_packages = []
    @path             = path
    @run_all          = @package.nil?
  end

  def run
    prepare!
    check_input_params!
    display_missing_specs
    execute_command
  end

  def packages
    @packages ||= Rdm::SpecRunner::PackageFetcher.new(@path).packages
  end

  def view
    @view ||= Rdm::SpecRunner::View.new
  end

  def print_message(msg)
    puts msg
    true
  end

  def exit_with_message(msg)
    print_message(msg)
    exit 1
  end

  def check_input_params!
    if @package_name
      unless is_package_included?(@package_name)
        exit_with_message(
          view.package_not_found_message(@package_name, prepared_command_params)
        )
      end

      if skipped_packages.include?(@package_name)
        exit_with_message(
          view.no_specs_for_package(@package_name)
        )
      end
    end
  end

  def is_package_included?(package_name)
    !prepared_command_params.select do |x|
      x.package_name == package_name
    end.empty?
  end

  def prepare!
    prepared_command_params = []
    skipped_packages        = []
    command                 = nil
    prepare_command_params
    prepare_skipped_packages
    prepare_command
  end

  def prepare_command_params
    @prepared_command_params ||= begin
      packages.map do |_name, package|
        Rdm::SpecRunner::CommandGenerator.new(
          package_name: package.name, package_path: package.path, spec_matcher: @spec_matcher
        ).generate
      end
    end
  end

  def prepare_skipped_packages
    prepared_command_params
      .select { |cp| cp.spec_count == 0 }
      .map { |cp| skipped_packages << cp.package_name }
  end

  def prepare_command
    @command ||= begin
      if @package_name
        prepare_single_package_command(@package_name)
      else
        prepare_command_for_packages(prepared_command_params)
      end
    end
  end

  def prepare_single_package_command(package_name)
    selected = prepared_command_params.select do |cmd_params|
      cmd_params.package_name == package_name
    end
    prepare_command_for_packages(selected)
  end

  def prepare_command_for_packages(packages_command_params)
    packages_command_params.select do |cmd_params|
      cmd_params.spec_count > 0
    end.sort_by do |cmd_params|
      - cmd_params.spec_count
    end.map(&:command).join(' && ')
  end

  def display_missing_specs
    unless skipped_packages.empty?
      print_message view.missing_specs_message(skipped_packages)
    end
  end

  def execute_command
    eval(command)
    if !$?.success?
      exit(1)
    end
  end
end