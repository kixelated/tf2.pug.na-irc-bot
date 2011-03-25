require_relative '../database'

require_relative 'match'
require_relative 'team'
require_relative 'user'

class Player
  include DataMapper::Resource
  
  belongs_to :match, :key => true
  belongs_to :user, :key => true
  belongs_to :team
  
  property :created_at, DateTime
end
