require 'dm-core'
require 'dm-aggregates'
require 'dm-migrations'
require 'dm-timestamps'

require_relative 'constants'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, Constants.const['database'])
