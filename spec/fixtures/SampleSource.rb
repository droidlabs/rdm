setup do
  role "example"
  config_path "config"
  silence_missing_package true
end

config :database

package "application/web"
package "domain/core"
