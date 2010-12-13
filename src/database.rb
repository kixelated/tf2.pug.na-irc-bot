require 'active_record'
require 'sqlite3'
require 'yaml'

dbconfig = YAML.load_file '../cfg/database.yml'
ActiveRecord::Base.establish_connection dbconfig
