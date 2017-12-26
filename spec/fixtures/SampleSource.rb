setup do
  role                    'example'
  config_path             'app.yml'
  silence_missing_package true
end

package "application/web"
package "domain/core"
