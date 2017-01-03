package do
  name "web"
  version "1.0"
end

dependency do
  import "core"
  require "active_support"
  require_file "lib/web.rb"
end

dependency :test do
  import "test_factory"
  require "rspec"
  require_file "lib/spec.rb"
end
