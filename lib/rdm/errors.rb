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
  end
end
