require 'rubygems'
require 'bundler/setup'
require "rdm"

Rdm.init(File.expand_path("../", __FILE__))

Web::SampleController.new.create_something