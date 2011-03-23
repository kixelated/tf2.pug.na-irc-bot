require_relative '../database'

require_relative 'match'
require_relative 'team'
require_relative 'user'

class Player
  include DataMapper::Resource
  
  belongs_to :match, :key => true
  belongs_to :user, :key => true, :index => :user_class
  
  belongs_to :team
  
  property :tfclass, Integer, :index => :user_class
  
  property :created_at, DateTime
  property :updated_at, DateTime
end
