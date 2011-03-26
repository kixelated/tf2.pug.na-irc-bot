require 'bundler/setup'

require_relative '../src/database'
require_relative '../src/irc/bot'

DataMapper.finalize
DataMapper.auto_upgrade!

start_bots!
