# frozen_string_literal: true
require 'simplecov'
SimpleCov.start do
  add_group 'Lib', 'lib'
end

ENV['RACK_ENV'] = 'test'
$VERBOSE = nil
require 'pry'
require 'minitest/autorun'
Dir.glob('./test/support/*.rb').each { |file| require file }

require 'mocha/mini_test'
require 'minitest-spec-context'
require 'rack/test'
