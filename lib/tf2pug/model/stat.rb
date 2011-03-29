require 'tf2pug/database'
require 'tf2pug/model/user'
require 'tf2pug/model/tfclass'

class Stat
  include DataMapper::Resource
  
  belongs_to :user,    :key => true
  belongs_to :tfclass, :key => true
  
  property :count, Integer, :default => 0
end
