require 'active_record'
require 'sqlite3'

require_relative 'constants'

database = Constants.const['database']
database['database'] = File.dirname(__FILE__) + '/' + database['database']
ActiveRecord::Base.establish_connection(database)
