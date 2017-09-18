class Rdm::CLI::DiffSpecRunner
  def self.run(revision: 'HEAD', path:, stdout: STDOUT, show_output: true)
    Rdm::CLI::DiffSpecRunner.new(revision, path, stdout, show_output).run
  end

  def initialize(revision, path, stdout, show_output)
    @revision    = revision
    @path        = path
    @stdout      = stdout
    @show_output = show_output
  end

  def run
    changed_packages = Rdm::Handlers::DiffPackageHandler.handle(
      path:     @path, 
      revision: @revision
    )
    
    if changed_packages.empty?
      @stdout.puts "No modified packages were found. Type `git add .` to index all changes..."
      
      return nil
    end

    @stdout.puts "Tests for the following packages will run:\n  - #{changed_packages.join("\n  - ")}\n\n"
  
    changed_packages.each do |package| 
      Rdm::SpecRunner.run(
        package:               package,
        path:                  @path,
        show_missing_packages: false,
        stdout:                @stdout,
        show_output:           @show_output
      )
    end
  
  rescue Rdm::Errors::GitRepositoryNotInitialized
    @stdout.puts "Git repository is not initialized. Use `git init .`"
    
    return nil
  end
end