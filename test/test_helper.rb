ENV['RACK_ENV'] = 'test'

require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  cover 'app.rb', 'lib/**/*.rb'
end

require 'minitest/autorun'
require 'rack/test'
require_relative '../app'
