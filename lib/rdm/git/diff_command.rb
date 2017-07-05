class Rdm::Git::DiffCommand
  class << self
    def get_only_diff_filenames(revision:, path:)
      command = `cd #{path} && git diff --name-only #{revision}`

      raise Rdm::Errors::GitCommandError, command unless $?.success?

      command.split("\n")
    end
  end
end
