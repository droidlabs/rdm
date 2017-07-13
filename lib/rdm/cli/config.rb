class Rdm::CLI::Config
  def self.run(current_path:, config_name:, config_data: {}, stdout: $stdout)
    Rdm::CLI::Config.new(current_path, config_name, config_data, stdout).run
  end

  def initialize(current_path, config_name, config_data, stdout)
    @current_path = current_path
    @config_name  = config_name
    @config_data  = config_data
    @stdout       = stdout
  end

  def run
    generated_files = Rdm::Gen::Config.generate(
      current_path: @current_path,
      config_name:  @config_name,
      config_data:  @config_data
    )

    puts "Following files were generated:"
    puts generated_files
  rescue Errno::ENOENT => e
    @stdout.puts "Error occurred. Possible reasons:\n #{Rdm::SOURCE_FILENAME} not found. Please run on directory containing #{Rdm::SOURCE_FILENAME} \n#{e.inspect}"
  rescue NoMethodError => e
    @stdout.puts e.message
  rescue Rdm::Errors::SourceFileDoesNotExist => e
    @stdout.puts "Rdm.packages was not found. Run 'rdm init' to create it"
  end
end