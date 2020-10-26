package do
  name "server"
  version "1.0"
end

dependency do
  set_package_env_file "env/%{env_name}.yml"

  import "web"
end