require 'active_record'
require 'sqlite3'

class Database

def initialize adapter, database

  ActiveRecord::Base.establish_connection(
      :adapter => adapter,
      :database  => database
  )
end

end