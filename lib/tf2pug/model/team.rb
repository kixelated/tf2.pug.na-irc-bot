require 'tf2pug/database'
require 'tf2pug/model/matchup'
require 'tf2pug/model/match'
require 'tf2pug/model/roster'
require 'tf2pug/model/user'

class Team
  include DataMapper::Resource
  
  property :id,   Serial
  property :name, String, :index => true, :required => true
  
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :matchups
  has n, :matches,  :through => :matchups
  has n, :rosters
  has n, :users,    :through => :rosters
  
  def leader; self.rosters.first(:leader => true); end
  
  def add_roster(user, leader = true)
    temp = rosters.create(:user => user)

    if temp and leader # operation was successful and user wants leader
      rosters.first(:leader => true).update(:leader => false)
      temp.update(:leader => true)
    end
  end

  def remove_roster(user)
    return unless temp = rosters.first(:user => user)
    
    # select a random new leader if deleting the current one
    rosters.first(:leader => false).update(:leader => true) if temp.leader
    temp.destroy
  end
end
