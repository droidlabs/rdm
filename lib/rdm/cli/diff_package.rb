class Rdm::CLI::DiffPackage
  class << self
    def run(opts = {})
      Rdm::CLI::DiffPackage.new(opts).run
    end
  end

  attr_reader :path, :git_point
  def initialize(path:, git_point:)
    @path      = path
    @git_point = git_point
  end

  def run
    begin
      puts Rdm::Handlers::DiffPackageHandler.handle(path: path, git_point: git_point)
    rescue Rdm::Errors::GitRepositoryNotInitialized
      puts "Git repository is not initialized. Use `git init .`"
    end      
  end
end