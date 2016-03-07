setup do
  role "example"
end

config :database

package "application/web"
package "domain/core"