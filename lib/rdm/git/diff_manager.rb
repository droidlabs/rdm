require 'fileutils'

module Rdm
  module Git
    class DiffManager
      GIT_ERROR_MESSAGE = "fatal: Not a git repository (or any of the parent directories): .git"
      DEFAULT_REVISION  = 'HEAD'

      class << self
        def run(path:, revision: nil)
          abs_path = Rdm::Git::RepositoryLocator.locate(path)

          check_repository_initialized!(abs_path)

          return Rdm::Git::DiffCommand
            .get_only_diff_filenames(revision: revision, path: path)
            .map { |filename| File.expand_path(File.join(abs_path, filename)) }
        end

        private

          def check_repository_initialized!(folder)
            unless %x( cd #{folder} && git status 2>&1 >/dev/null ).empty?
              raise Rdm::Errors::GitRepositoryNotInitialized 
            end
          end
      end
    end
  end
end