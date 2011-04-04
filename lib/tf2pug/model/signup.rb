require 'tf2pug/database'
require 'tf2pug/model/pug'
require 'tf2pug/model/user'
require 'tf2pug/model/tfclass'

class Signup
  include DataMapper::Resource
  
  belongs_to :pug, :key => true
  property   :id,  Serial
  
  belongs_to :user
  belongs_to :tfclass
end
