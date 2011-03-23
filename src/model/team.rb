require_relative '../database'

require_relative 'match'
require_relative 'player'
require_relative 'user'

class Team
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :index => true

  has n, :matches, :through => Resource
  has n, :players
  has n, :users, :through => Resource
  
  property :created_at, DateTime
  property :updated_at, DateTime
end
