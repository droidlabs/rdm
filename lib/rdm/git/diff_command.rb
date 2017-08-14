class Rdm::Git::DiffCommand
  GIT_FILE_REPLACE_REGEX = /{(?<old>[\w_\d\.]+)\s*=>\s*(?<new>[\w_\d\.]+)}/

  class << self
    def get_only_diff_filenames(revision:, path:)
      command = `cd #{path} && git diff --name-only #{revision}`

      raise Rdm::Errors::GitCommandError, command unless $?.success?

      command.split("\n")
    end

    def get_diff_stat(revision:, path:)
      command = `cd #{path} && git diff --stat #{revision}`
      
      raise Rdm::Errors::GitCommandError, command unless $?.success?

      format_diff_stat_command(command)
    end

    private

    def format_diff_stat_command(command)
      files_list = command
        .split("\n")[0..-2] # remove last string with statistics
        .map do |stat_string|
          file_name = stat_string.split('|').first.strip

          match_data = GIT_FILE_REPLACE_REGEX.match(file_name)

          if match_data
            file_name = [
              file_name.gsub(GIT_FILE_REPLACE_REGEX, match_data[:old]),
              file_name.gsub(GIT_FILE_REPLACE_REGEX, match_data[:new])
            ]
          end

          file_name
        end

      files_list.flatten
    end
  end
end
