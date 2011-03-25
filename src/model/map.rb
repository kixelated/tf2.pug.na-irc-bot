require_relative '../database'

require_relative 'match'

class Map
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :required => true
  property :file, String, :unique => true, :required => true
  property :weight, Integer, :gt => 0

  has n, :matches
  
  property :played_at, DateTime, :index => true
  property :created_at, DateTime
  property :updated_at, DateTime
end
