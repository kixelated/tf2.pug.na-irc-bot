require 'tf2pug/database'
require 'tf2pug/model/pug'
require 'tf2pug/model/team'
require 'tf2pug/model/user'
require 'tf2pug/model/tfclass'

class Pick
  include DataMapper::Resource
  
  belongs_to :pug,  :key => true
  belongs_to :team, :key => true
  belongs_to :user, :key => true, :index => :tfclass_user
  
  belongs_to :tfclass, :index => :tfclass_user
  
  is :list, :scope => [ :pug_id, :team_id ]
end

module PickOperations

end
