require 'tf2pug/database'
require 'tf2pug/model/roster'
require 'tf2pug/model/team'
require 'tf2pug/model/signup'

class User
  include DataMapper::Resource
 
  property :id, Serial
  property :auth, String, :index => :auth_nick
  property :nick, String, :index => :auth_nick, :unique => :auth, :required => true
  
  property :restricted_at, DateTime, :index => true
 
  has n, :rosters, :constraint => :destroy
  has n, :teams,   :through => :rosters
  has n, :signups, :constraint => :destroy
  has n, :picks
  
  property :spoken_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime
  
  class << self
    cache = {} # TODO: Might be @cache
    
    def create_player player
      cache[player] = User.create(:auth => player.authname, :nick => player.nick)
    end
  
    def find_player player
      return cache[player] if cache.key?(player)
      
      if user = User.first(:auth => player.authname) if player.authed? # select by auth
        user.update(:nick => player.nick) if user.nick != player.nick # update user's nick
      else
        user = User.first(:nick => player.nick, :auth => nil) # select by nick
        user.update(:auth => player.authname) if user and player.authed? # update user's auth
      end
      
      cache[player] = user
    end
    
    def update_cache player, replacement = nil
      temp = cache.delete player
      cache[replacement] = temp if replacement
    end
  end
  
  def restricted?
    @restricted_at > 0
  end
  
  def restrict duration
    update(:restricted_at => Time.now.to_i + duration)
  end
  
  def authorize
    update(:restricted_at => 0)
  end
end
