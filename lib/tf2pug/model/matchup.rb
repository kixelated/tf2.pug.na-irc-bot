require 'tf2pug/database'
require 'tf2pug/model/match'
require 'tf2pug/model/team'

class Matchup
  include DataMapper::Resource
  
  belongs_to :match, :key => true
  property   :id,    Serial
  
  belongs_to :team, :index => true
end
