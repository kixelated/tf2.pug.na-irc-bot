require_relative '../database'

require_relative 'user'
require_relative 'tfclass'

class Stat
  include DataMapper::Resource
  
  belongs_to :user,    :key => true
  belongs_to :tfclass, :key => true
  
  property :count, Integer, :default => 0
  
  validates_numericality_of :count, :gte => 0
end
