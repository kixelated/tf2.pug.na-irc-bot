require 'dm-core'
require 'dm-aggregates'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-is-state_machine'

require_relative 'constants'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, Constants.database)
