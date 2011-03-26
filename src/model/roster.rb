require_relative '../database'

require_relative 'team'
require_relative 'user'

class Roster
  include DataMapper::Resource
  
  belongs_to :team, :key => true
  belongs_to :user, :key => true
  
  property :captain, Boolean
  property :created_at, DateTime
  
  validates_uniqueness_of :captain, :scope => :team
end
