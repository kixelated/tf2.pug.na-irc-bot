require 'tf2pug/database'
require 'tf2pug/model/matchup'
require 'tf2pug/model/user'
require 'tf2pug/model/tfclass'

class Pick
  include DataMapper::Resource
  
  belongs_to :matchup, :key => true
  belongs_to :user,    :key => true, :index => :tfclass_user
  belongs_to :tfclass, :index => :tfclass_user
end
