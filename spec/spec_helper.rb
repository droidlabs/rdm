require 'simplecov'
require 'rdm'
require 'byebug'
require 'fileutils'

require_relative 'helpers/example_project_helper'
require_relative 'helpers/git_commands_helper'

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/.direnv/"
  add_filter "/rdm/templates"
end
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

Rdm.setup do
  silence_missing_package_file true
end

RSpec.configure do |config|
  config.color = true
end

def ensure_exists(file)
  expect(File.exists?(file)).to be true
end

def ensure_content(file, content)
  expect(File.read(file)).to match(content)
end

class SpecLogger
  attr_reader :output
  def initialize
    @output = []
  end

  def puts(message)
    @output.push(message)
  end

  def clean
    @output = []
  end
end

module SetupHelper
end
