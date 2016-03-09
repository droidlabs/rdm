require 'rdm'

Rdm.setup do
  silence_missing_package_file_exception(true)
end

RSpec.configure do |config|
  config.color = true
end

