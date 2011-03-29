require_relative '../database'

require_relative 'roster'
require_relative 'team'
require_relative 'stat'
require_relative 'signup'

class User
  include DataMapper::Resource
 
  property :id, Serial
  property :auth, String, :index => :auth_nick
  property :nick, String, :index => :auth_nick, :unique => :auth, :required => true
  
  property :restricted_at, DateTime, :index => true
 
  has n, :rosters, :constraint => :destroy
  has n, :teams,   :through => :rosters
  has n, :stats,   :constraint => :destroy
  has n, :signups, :constraint => :destroy
  has n, :picks
  
  property :created_at, DateTime
  property :updated_at, DateTime
end
