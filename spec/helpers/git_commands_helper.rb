module GitCommandsHelper
  def git_initialize_repository(path)
    %x( cd #{path} && git init )
  end

  def git_commit_changes(path)
    %x( cd #{path} && git add . && git commit -m 'Some commit' )
  end

  def git_index_changes(path)
    %x( cd #{path} && git add . )
  end
end