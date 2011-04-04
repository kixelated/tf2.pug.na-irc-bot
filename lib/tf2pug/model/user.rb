require 'tf2pug/database'
require 'tf2pug/model/roster'
require 'tf2pug/model/team'
require 'tf2pug/model/signup'
require 'tf2pug/model/pick'

class User
  include DataMapper::Resource
 
  property :id, Serial
  property :auth, String, :index => :auth_nick
  property :nick, String, :index => :auth_nick, :required => true
  
  property :restricted_at, DateTime, :index => true
 
  has n, :rosters
  has n, :teams,   :through => :rosters
  has n, :picks
  has n, :signups
  
  property :spoken_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime
  
  @cache = {}
  class << self
    def create_player player
      @cache[player] = User.first_or_create(:auth => player.authname, :nick => player.nick)
    end
  
    def find_player player
      return @cache[player] if @cache.key?(player)
      
      if player.authed?
        user = User.first(:auth => player.authname) # select by auth
        user = User.first(:nick => player.nick, :auth => nil) unless user # select by nick if fails
        user.update(:nick => player.nick, :auth => player.authname) if user # update nick and auth
      else
        user = User.first(:nick => player.nick, :auth => nil) # select by nick
      end
      
      @cache[player] = user
    end
    
    def update_cache player, replacement = nil
      temp = @cache.delete player
      @cache[replacement] = temp if replacement
    end
  end
  
  def restricted?
    @restricted_at != nil
  end
  
  def restrict duration
    update(:restricted_at => Time.now.to_i + duration)
  end
  
  def authorize
    update(:restricted_at => nil)
  end
end
