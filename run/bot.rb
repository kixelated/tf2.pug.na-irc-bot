require 'bundler/setup'

require_relative '../src/database'
require_relative '../src/irc/bot'

DataMapper.finalize
start_bots!
