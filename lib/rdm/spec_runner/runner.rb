class Rdm::SpecRunner::Runner
  RUNIGNORE_PATH    = 'tests/.runignore'.freeze
  RUNIGNORE_COMMENT = '#'

  attr_accessor :no_specs_packages
  attr_accessor :prepared_command_params

  def initialize(
    package:               nil,
    spec_matcher:          nil,
    path:                  nil,
    from:                  nil,
    show_missing_packages: true,
    skip_ignored_packages: false,
    stdout:                STDOUT,
    show_output:           true
  )
    @package_name          = package
    @no_specs_packages     = []
    @spec_matcher          = spec_matcher.to_s.split(':')[0]
    @spec_string_number    = spec_matcher.to_s.split(':')[1].to_i
    @path                  = path
    @run_all               = @package_name.nil?
    @show_missing_packages = show_missing_packages && !@package_name
    @skip_ignored_packages = skip_ignored_packages
    @skipped_packages      = []
    @stdout                = stdout
    @show_output           = show_output
    @from                  = from
    @command_params_list          = []
  end

  def run
    if !@spec_matcher.nil? && !@spec_matcher.empty?
      @spec_file_matches = Rdm::SpecRunner::SpecFilenameMatcher.find_matches(package_path: packages[@package_name].path, spec_matcher: @spec_matcher)
      case @spec_file_matches.size
      when 0
        raise Rdm::Errors::SpecMatcherNoFiles, "No specs were found for '#{@spec_matcher}'"
      when 1
        format_string_number = @spec_string_number == 0 ? "" : ":#{@spec_string_number}"
        @spec_matcher = @spec_file_matches.first + format_string_number

        @stdout.puts "Following spec matches your input: #{@spec_matcher}"
      else
        raise Rdm::Errors::SpecMatcherMultipleFiles, @spec_file_matches.join("\n")
      end
    end

    prepare!
    check_input_params!
    display_missing_specs if @show_missing_packages
    display_ignored_specs if @skip_ignored_packages
    print_message view.specs_header_message if @show_missing_packages || @skip_ignored_packages

    execute_command
  end

  def packages
    @packages ||= Rdm::SpecRunner::PackageFetcher.new(@path).packages
  end

  def view
    @view ||= Rdm::SpecRunner::View.new
  end

  def print_message(msg)
    @stdout.puts msg
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

      if no_specs_packages.include?(@package_name)
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
    no_specs_packages       = []
    @command_params_list            = []
    prepare_command_params
    prepare_no_specs_packages
    prepare_command
  end

  def prepare_command_params
    @prepared_command_params ||= begin
      packages.map do |_name, package|
        Rdm::SpecRunner::CommandGenerator.new(
          package_name: package.name,
          package_path: package.path,
          spec_matcher: @spec_matcher,
          show_output:  @show_output
        ).generate
      end
    end
  end

  def prepare_no_specs_packages
    prepared_command_params
      .select { |cp| cp.spec_count == 0 }
      .map { |cp| no_specs_packages << cp.package_name }
  end

  def prepare_command
    if @package_name
      @command_params_list += prepare_single_package_command(@package_name)
    else
      @command_params_list += prepare_commands_for_packages(prepared_command_params)
    end
  end

  def prepare_single_package_command(package_name)
    selected = prepared_command_params.detect do |cmd_params|
      cmd_params.package_name == package_name
    end
    prepare_commands_for_packages([selected])
  end

  def prepare_commands_for_packages(packages_command_params)
    if @skip_ignored_packages && !@package_name
      runignore_path = File.expand_path(File.join(Rdm.root_dir, RUNIGNORE_PATH))
      package_list   = Rdm::SourceParser.read_and_init_source(Rdm.root).packages.keys

      skipped_package_list = File.read(runignore_path)
        .lines
        .map(&:strip)
        .reject(&:empty?) rescue []

      @skipped_packages       = skipped_package_list.select {|line| package_list.include?(line)}
      comment_runignore_lines = skipped_package_list.select {|line| line.start_with?(RUNIGNORE_COMMENT)}
      invalid_ignore_packages = skipped_package_list - @skipped_packages - comment_runignore_lines

      if !invalid_ignore_packages.empty?
        @stdout.puts "WARNING: #{RUNIGNORE_PATH} contains invalid package names: \n#{invalid_ignore_packages.join("\n")}"
      end
    else
      @skipped_packages = []
    end

    running_packages = packages_command_params
      .select  { |cmd_params| cmd_params.spec_count > 0 }
      .reject  { |cmd_params| @skipped_packages.include?(cmd_params.package_name) }
      .sort_by { |cmd_params| cmd_params.package_name }

    if @from
      start_from = running_packages.index {|cmd_params| cmd_params.package_name == @from}

      if start_from.nil?
        puts "Package :#{@from} does not exists"
        exit(1)
      end

      if @skipped_packages.include?(start_from)
        puts "Package :#{@from} skipped by .runignore file"
        exit(1)
      end

      running_packages = running_packages[start_from..-1]
    end

    if @run_all
      puts <<~EOF
        Rspec tests will run for packages:
        #{(packages.keys - no_specs_packages).map {|pkg| " - #{pkg}"}.sort.join("\n")}\n
      EOF
    end

    running_packages
  end

  def display_missing_specs
    if !no_specs_packages.empty?
      print_message view.missing_specs_message(no_specs_packages)
    end
  end

  def display_ignored_specs
    if !@skipped_packages.empty?
      print_message view.skipping_specs_message(@skipped_packages)
    end
  end

  def execute_command
    @command_params_list.each do |command_param|
      eval(command_param.command);

      command_param.exitstatus = $?.exitstatus
    end

    failed = @command_params_list.select {|cmd_param| !cmd_param.success?}

    if failed.any?
      total_count = @command_params_list.count
      failed_count = failed.count

      print_message("#{failed_count} of #{total_count} packages failed:")
      print_message(failed.map(&:package_name))
      print_message("\n")

      exit(1)
    end
  end
end