require 'tf2pug/database'
require 'tf2pug/model/match'
require 'tf2pug/model/team'

class Matchup
  include DataMapper::Resource
  
  belongs_to :match, :key => true
  belongs_to :team,  :key => true
  
  property :home, Boolean
end
