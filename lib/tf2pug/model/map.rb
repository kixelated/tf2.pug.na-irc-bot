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
  
  # random based on weights
  def self.random
    target = rand(self.all.sum(:weight))
    
    self.all.detect do |map|
      target -= map.weight
      target < 0
    end 
  end
end
