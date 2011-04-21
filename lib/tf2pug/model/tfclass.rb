require 'tf2pug/database'

class Tfclass
  include DataMapper::Resource
  
  property :id,        Serial
  property :name,      String,  :required => true
  property :pug_count, Integer, :default => 0
  
  class << self
    def pug; self.all(:pug_count.gte => 1); end
  end
end
