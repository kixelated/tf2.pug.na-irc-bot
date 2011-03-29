require 'tf2pug/database'
require 'tf2pug/model/match'

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
    maps = Map.all
    weight = maps.sum(:weight)
    
    maps.shuffle.each do |map|
      return map if rand(weight) < map.weight
    end
    
    return maps.last # could not find a map, play the newest map
  end
end
