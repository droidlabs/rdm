module Rdm
  SOURCE_FILENAME = "Rdm.packages"
  PACKAGE_FILENAME = "Package.rb"
  PACKAGE_LOCK_FILENAME = "#{PACKAGE_FILENAME}.lock"

  require "rdm/source_parser"
  require "rdm/source_installer"
  require "rdm/package"
  require "rdm/package_parser"
  require "rdm/package_importer"

  class << self
    # Initialize current package using Package.rb
    def init(package_path, group = nil)
      Rdm::PackageImporter.import_file(package_path, group: group)
    end
  end
end