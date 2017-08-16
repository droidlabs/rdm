module Rdm::SpecRunner
  def self.run(
    path:                  nil, 
    package:               nil, 
    spec_matcher:          nil, 
    show_missing_packages: true, 
    skip_ignored_packages: false,
    stdout:                STDOUT,
    stdin:                 STDIN
  )
    Rdm::SpecRunner::Runner.new(
      path:                  path, 
      package:               package, 
      spec_matcher:          spec_matcher, 
      show_missing_packages: show_missing_packages,
      skip_ignored_packages: skip_ignored_packages
    ).run

  rescue Rdm::Errors::SpecMatcherNoFiles => e
    stdout.puts e.message
  rescue Rdm::Errors::SpecMatcherMultipleFiles => e
    spec_files        = e.message.split("\n")
    format_spec_files = spec_files.map.with_index {|file, idx| "#{idx+1}. #{file}"}.join("\n")
    
    stdout.puts "Following specs match your input:"
    stdout.puts format_spec_files
    stdout.print "Enter space-separated file numbers, ex: '1 2': "
    selected_files_numbers = stdin.gets.chomp
      .split(' ')
      .map {|x| Integer(x) rescue nil }
      .compact
      .map {|n| n - 1}
      .reject {|n| n >= spec_files.size}

    spec_files
      .select
      .with_index {|_file, idx| selected_files_numbers.include?(idx)}
      .each do |file|
        Rdm::SpecRunner::Runner.new(
          path:                  path, 
          package:               package, 
          spec_matcher:          file, 
          show_missing_packages: show_missing_packages,
          skip_ignored_packages: skip_ignored_packages
        ).run
      end
  end
end