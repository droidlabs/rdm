require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/.direnv/"
  add_filter "/rdm/templates"
end

require 'rdm'
require 'byebug'
require 'fileutils'

require_relative 'helpers/example_project_helper'
require_relative 'helpers/git_commands_helper'

if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

# setup GIT so specs for GIT run properly on Travis
if ENV['CI'] == 'true'
  %x{ git config --global user.email "travisci@example.com" }
  %x{ git config --global user.name "TravisCI Developer" }
end


Rdm.setup do
  silence_missing_package_file true
  config_path                  File.join(__dir__, 'fixtures', 'app.yml')
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

  def initialize(stdin: nil)
    @stdin  = stdin
    @output = []
  end

  def puts(message)
    @output.push(message)
  end
  
  def print(message)
    @output.push(message)
  end

  def clean
    @output = []
  end

  def gets
    @stdin
  end
end

module SetupHelper
end
