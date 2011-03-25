require_relative '../database'

require_relative 'stat'

class Tfclass
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  
  has n, :stats
end
