require 'rdm'

Rdm.setup do
  silence_missing_package_file(true)
end

RSpec.configure do |config|
  config.color = true
end

