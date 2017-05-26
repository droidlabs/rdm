class Rdm::Git::RepositoryLocator
  GIT_FOLDER = '.git'

  class << self 
    def locate(path)
      raise Rdm::Errors::GitRepositoryNotInitialized, path if root_reached?(path)
      
      return path if git_present?(path)
      
      locate(File.dirname(path))
    end

    def root_reached?(path)
      File.expand_path(path) == '/'
    end

    def git_present?(path)
      expected_source_file = File.join(path, GIT_FOLDER)
      
      File.exist?(expected_source_file)
    end
  end
end