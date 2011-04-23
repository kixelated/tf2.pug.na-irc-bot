require 'dm-core'
require 'dm-aggregates'
require 'dm-is-list'
require 'dm-is-state_machine'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-validations'

require 'tf2pug/constants'

#DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite:" + File.dirname(__FILE__) + "/../../db/stats.sqlite3")
