require_relative '../database'

require_relative 'match'
require_relative 'matchup'
require_relative 'roster'
require_relative 'user'

class Team
  include DataMapper::Resource
  
  property :id,   Serial
  property :name, String, :index => true
  
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :matchups
  has n, :matches,  :through => :matchups
  has n, :rosters
  has n, :users,    :through => :rosters
  
  validates_presence_of :name
end
