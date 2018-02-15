module Rdm
  module Errors
    class ProjectAlreadyInitialized < StandardError
    end
    class PackageExists < StandardError
    end

    class PackageDirExists < StandardError
    end

    class SourceFileDoesNotExist < StandardError
      attr_reader :message
      def initialize(message = nil)
        @message = message || "Rdm.packages was not found. Run 'rdm init' to create it"
      end
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

    class InvalidParams < StandardError
    end

    class InvalidProjectDir < StandardError
    end

    class PackageHasNoDependencies < StandardError
    end

    class SpecMatcherNoFiles < StandardError
    end

    class SpecMatcherMultipleFiles < StandardError
    end

    class ConfigExists < StandardError
    end

    class InvalidConfig < StandardError
    end
  end
end
