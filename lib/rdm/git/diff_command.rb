require 'open3'

class Rdm::Git::DiffCommand
  class << self
    def get_only_diff_filenames(revision:, path:)
      command = "git diff #{revision} --name-only"

      Open3.popen3(command, chdir: path) do |stdin, stdout, stderr, wait_thr|
        raise Rdm::Errors::GitCommandError, stderr.read if !wait_thr.value.success?
      
        stdout.read.split("\n")
      end
    end
  end
end