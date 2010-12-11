require 'sqlite3'
require 'active_record'
require './players.rb'

dbconnection = ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database  => './dat/botdata.db'
)

dude = Player.create(:steam_id => 'STEAM_0:1:123456',
    :auth_name => 'Faek')
