require 'bundler/setup'

Dir["../../src/model/*.rb"].each { |file| require_relative file }

DataMapper.finalize
DataMapper.auto_upgrade!
