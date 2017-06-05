module Rdm
  module Errors
    class ProjectAlreadyInitialized < StandardError
    end
    class PackageExists < StandardError
    end

    class PackageDirExists < StandardError
    end

    class SourceFileDoesNotExist < StandardError
    end
    
    class GitRepositoryNotInitialized < StandardError
    end

    class PackageFileDoesNotFound < StandardError
    end

    class GitCommandError < StandardError
    end

    class PackageDoesNotExist < StandardError
    end

    class TemplateVariableNotDefined < StandardError
    end

    class TemplateDoesNotExist < StandardError
    end

    class TemplateFileExists < StandardError
    end

    class PackageNameNotSpecified < StandardError
    end

    class ProjectDirNotSpecified < StandardError
    end

    class InvalidProjectDir < StandardError
    end
  end
end
