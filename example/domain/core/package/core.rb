require 'active_support'
require 'active_support/dependencies'
require 'active_support/core_ext'

ActiveSupport::Dependencies.autoload_paths << Pathname.new(__FILE__).parent.to_s

module Core
end