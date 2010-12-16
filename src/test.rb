require 'rubygems'
require 'active_record'
require 'yaml'

dbconfig = YAML::load(File.open('../cfg/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

class Player < ActiveRecord::Base
end

temp = Player.new
temp.name = "pingu"
temp.save