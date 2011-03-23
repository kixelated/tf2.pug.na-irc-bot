require_relative '../database'

require_relative 'map'
require_relative 'team'
require_relative 'player'
require_relative 'server'

class Match
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :map
  belongs_to :server
  
  has n, :players
  has n, :teams, :through => Resource
  
  has n, :users, :through => :players
  
  property :created_at, DateTime
  property :updated_at, DateTime
end
