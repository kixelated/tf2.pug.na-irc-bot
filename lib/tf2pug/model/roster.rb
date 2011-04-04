require 'tf2pug/database'
require 'tf2pug/model/team'
require 'tf2pug/model/user'

class Roster
  include DataMapper::Resource
  
  belongs_to :team, :key => true
  belongs_to :user, :key => true
  
  property :leader, Boolean
   
  property :created_at, DateTime
end
