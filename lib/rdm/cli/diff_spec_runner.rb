class Rdm::CLI::DiffSpecRunner
  def self.run(revision: 'HEAD', path:)
    Rdm::CLI::DiffSpecRunner.new(revision, path).run
  end

  def initialize(revision, path)
    @revision = revision
    @path     = path
  end

  def run
    changed_packages = Rdm::Handlers::DiffPackageHandler.handle(
      path:     @path, 
      revision: @revision
    )
    
    if changed_packages.empty?
      puts "No modified packages were found. Type `git add .` to index all changes..."
      exit(1)
    end

    puts "Tests for the following packages will run:\n  - #{changed_packages.join("\n  - ")}\n\n"
  
    changed_packages.each do |package| 
      Rdm::SpecRunner.run(
        package:               package,
        path:                  @path,
        show_missing_packages: false
      )
    end
  
  rescue Rdm::Errors::GitRepositoryNotInitialized
    puts "Git repository is not initialized. Use `git init .`"
    exit(1)
  end
end