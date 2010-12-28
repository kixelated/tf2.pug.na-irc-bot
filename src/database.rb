require 'active_record'
require 'sqlite3'

require_relative 'constants'

ActiveRecord::Base.establish_connection Constants.const["database"]
