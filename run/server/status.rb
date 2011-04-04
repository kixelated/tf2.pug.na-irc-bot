require_relative '../config'
require_relative '../fakebot'

require 'tf2pug/database'
require 'tf2pug/logic/server'

DataMapper.finalize

ServerLogic::list_status
