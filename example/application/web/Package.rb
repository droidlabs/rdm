package do
  name "web"
  version "1.0"
end

dependency do
  import "core"
end

dependency :test do
  import "repository"
end