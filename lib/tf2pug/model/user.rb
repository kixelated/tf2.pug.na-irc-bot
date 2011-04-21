require 'tf2pug/database'
require 'tf2pug/model/roster'
require 'tf2pug/model/team'
require 'tf2pug/model/signup'
require 'tf2pug/model/pick'

class User
  include DataMapper::Resource
 
  property :id,   Serial
  property :auth, String, :index => :auth_nick
  property :nick, String, :index => :auth_nick, :required => true
  
  property :restricted_at, DateTime, :index => true
 
  has n, :rosters
  has n, :teams,   :through => :rosters
  has n, :picks
  has n, :signups
  
  property :spoken_at,  DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

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
