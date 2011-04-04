require_relative '../config'
require_relative '../fakebot'

require 'tf2pug/database'
require 'tf2pug/logic/server'

DataMapper.finalize

ServerLogic::download_demos
ServerLogic::purge_demos
ServerLogic::upload_demos
