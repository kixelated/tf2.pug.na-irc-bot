require 'tf2pug/database'
require 'tf2pug/model/pug'
require 'tf2pug/model/tfclass'
require 'tf2pug/model/user'

class Signup
  include DataMapper::Resource
  
  belongs_to :pug,  :key => true
  belongs_to :user, :key => true
  
  has n, :tfclasses, :through => Resource
end
