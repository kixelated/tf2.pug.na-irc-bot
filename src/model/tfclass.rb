require_relative '../database'

require_relative 'stat'

class Tfclass
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :required => true
  
  has n, :stats
end
