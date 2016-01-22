package do
  name "core"
  version "1.0"
end

dependency do
  require_file "lib/core.rb"

  import "repository"
end