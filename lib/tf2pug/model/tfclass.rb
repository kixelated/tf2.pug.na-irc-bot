require 'tf2pug/database'
require 'tf2pug/model/stat'

class Tfclass
  include DataMapper::Resource
  
  property :id,   Serial
  property :name, String,  :required => true
  property :pug,  Integer, :default => 0
     
  has n, :stats
end
