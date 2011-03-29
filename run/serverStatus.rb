require 'bundler/setup'

require_relative '../src/logic/server'

def message msg
  puts msg
end

DataMapper.finalize

ServerLogic::list_status
