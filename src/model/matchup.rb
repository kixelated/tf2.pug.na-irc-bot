require_relative '../database'

require_relative 'match'
require_relative 'team'
require_relative 'pick'

class Matchup
  include DataMapper::Resource
  
  belongs_to :match, :key => true
  belongs_to :team,  :key => true
  
  property :home, Boolean, :unique => :match
  
  has n, :picks, :constraint => :destroy
end
