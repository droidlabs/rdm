ENV['RUBY_ENV'] = 'test'

require 'rdm'
Rdm.init(File.expand_path('../../', FILE), :test)

require 'rspec'
require 'byebug'

RSpec.configure do |config|
end
