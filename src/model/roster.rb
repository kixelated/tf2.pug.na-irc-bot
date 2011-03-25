require_relative '../database'

require_relative 'team'
require_relative 'user'

class Roster
  include DataMapper::Resource
  
  belongs_to :team, :key => true
  belongs_to :user, :key => true
  
  property :captain, Boolean, :unique => [ :scope => :team ]
  
  property :created_at, DateTime
end
