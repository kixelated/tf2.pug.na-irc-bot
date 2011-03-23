require_relative '../database'

require_relative 'match'
require_relative 'player'
require_relative 'team'

class User
  include DataMapper::Resource
 
  property :id, Serial
  property :auth, String, :index => :auth_nick
  property :nick, String, :index => :auth_nick
  
  property :restricted_at, DateTime, :index => true
 
  has n, :players
  has n, :teams, :through => Resource
  
  has n, :matches, :through => :players
  
  property :created_at, DateTime
  property :updated_at, DateTime
end
