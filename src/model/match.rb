require_relative '../database'

require_relative 'map'
require_relative 'matchup'
require_relative 'team'
require_relative 'server'

class Match
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :map
  belongs_to :server
  
  property :played_at,  DateTime, :index => true
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has 2, :matchups
  has 2, :teams,    :through => :matchups
end
