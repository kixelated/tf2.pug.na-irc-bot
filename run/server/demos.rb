require 'bundler/setup'

require_relative '../../src/logic/server'

def message msg
  puts msg
end

DataMapper.finalize

ServerLogic::download_demos
ServerLogic::purge_demos
ServerLogic::upload_demos
