module Rdm
  module Git
    class DiffManager
      GIT_DIFF_REGEXP = /([\w\/.-]*)/i
      GIT_ERROR_MESSAGE = "fatal: Not a git repository (or any of the parent directories): .git"

      class << self
        def run(path:, git_point: 'HEAD')
          abs_path = Rdm::Git::RepositoryLocator.locate(path)

          check_repository_initialized!(abs_path)

          git_diff_result = %x( cd #{abs_path} && git diff #{git_point} --name-only )

          return git_diff_result
            .split("\n")
            .map { |string| GIT_DIFF_REGEXP.match(string).to_a.last }
            .reject(&:blank?)
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