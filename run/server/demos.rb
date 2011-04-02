require 'bundler/setup'

$:.push('../../lib')

require 'tf2pug/database'
require 'tf2pug/logic/server'

def message msg
  puts msg
end

DataMapper.finalize

ServerLogic::download_demos
ServerLogic::purge_demos
ServerLogic::upload_demos
