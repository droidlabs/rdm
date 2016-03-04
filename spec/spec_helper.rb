require 'rdm'

Rdm.setup do
  raises_missing_package_file_exception(false)
end

RSpec.configure do |config|
  config.color = true
end

