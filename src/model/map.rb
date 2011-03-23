require_relative '../database'

require_relative 'match'

class Map
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :file, String
  property :weight, Integer, :index => true

  has n, :matches
  
  property :created_at, DateTime
  property :updated_at, DateTime
end
