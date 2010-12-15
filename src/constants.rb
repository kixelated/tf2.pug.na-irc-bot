require 'yaml'
require 'active_record'
require 'sqlite3'

require './util.rb'

module Constants
  @@const = YAML.load_file '../cfg/constants.yml'

  def self.const
    @@const
  end
  
  def const
    @@const
  end
  
  def self.calculate
    @@const["teams"]["count"] = @@const["teams"]["details"].size
    @@const["teams"]["total"] = @@const["teams"]["players"] * @@const["teams"]["count"]
  end
end

Constants.calculate

dbconfig = YAML.load_file '../cfg/database.yml'
ActiveRecord::Base.establish_connection dbconfig