require 'bundler/setup'

$:.push('../../lib')

require 'tf2pug/database'
require 'tf2pug/logic/server'

def message msg
  puts msg
end

DataMapper.finalize

ServerLogic::list_status
