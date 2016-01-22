package do
  name "repository"
  version "1.0"
end

dependency do
  require_file "lib/repository.rb"

  require "sequel"
end