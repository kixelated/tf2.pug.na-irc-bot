require_relative '../database'

require_relative 'match'

class Map
  include DataMapper::Resource
  
  property :id,     Serial
  property :name,   String
  property :file,   String
  property :weight, Integer, :index => true
  
  property :played_at,  DateTime, :index => true
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :matches
  
  validates_uniqueness_of :file
  validates_numericality_of :weight, :gte => 0
end
