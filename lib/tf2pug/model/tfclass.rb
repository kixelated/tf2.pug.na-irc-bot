require 'tf2pug/database'

class Tfclass
  include DataMapper::Resource
  
  property :id,   Serial
  property :name, String,  :required => true
  property :pug,  Integer, :default => 0
end
