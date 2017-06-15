require 'open3'

class Rdm::Git::DiffCommand
  class << self
    def get_only_diff_filenames(revision:, path:)
      command = `git diff #{revision} --name-only`

      raise Rdm::Errors::GitCommandError, command unless $?.success?
    
      command.split("\n")
    end
  end
end