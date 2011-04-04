require 'tf2pug/database'
require 'tf2pug/model/pug'
require 'tf2pug/model/user'
require 'tf2pug/model/tfclass'

class Signup
  include DataMapper::Resource
  
  belongs_to :pug,     :key => true
  belongs_to :user,    :key => true
  belongs_to :tfclass, :key => true
end
