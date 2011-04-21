require 'tf2pug/database'
require 'tf2pug/model/matchup'
require 'tf2pug/model/match'
require 'tf2pug/model/member'
require 'tf2pug/model/user'

class Team
  include DataMapper::Resource
  
  property :id,   Serial
  property :name, String, :index => true, :required => true
  
  property :pug,  Boolean
  
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :matchups
  has n, :matches,  :through => :matchups
  
  has n, :members
  has n, :users,   :through => :members
  
  include MemberOperations
  
  class << self
    def random(count = 1)
      Team.all(:pug => true).shuffle.first(count)
    end
  end
end
