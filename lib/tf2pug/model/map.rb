require 'tf2pug/database'

class Map
  include DataMapper::Resource
  
  property :id,     Serial
  property :name,   String
  property :file,   String, :unique => true
  property :weight, Float,  :index => true
  
  property :played_at,  DateTime, :index => true
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :matches
  
  # random based on weights
  def self.random
    weight = self.all.sum(:weight)
    maps = self.all.select do { |map| map.weight > rand(weight) }
    
    maps.shuffle.first or self.first(:order => :played_at.asc)
  end
end
